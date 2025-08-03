import Foundation
import Supabase
import FactoryKit
import UIKit

// MARK: - Error Types

enum AvatarError: LocalizedError {
    case notAuthenticated
    case profileNotFound
    case networkError(String)
    case databaseError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to view avatar data"
        case .profileNotFound:
            return "User profile not found"
        case .networkError(let message):
            return "Network error: \(message)"
        case .databaseError(let message):
            return "Database error: \(message)"
        case .unknownError(let message):
            return message
        }
    }
    
    init(message: String) {
        self = .unknownError(message)
    }
}

// MARK: - Models

@MainActor
struct AvatarData {
    let profile: Profile
    let currentXP: Int
    let currentLevel: Int
    let xpToNextLevel: Int
    let progressToNextLevel: Double
    let currentStreak: Int
    
    init(profile: Profile, currentXP: Int, currentLevel: Int, xpToNextLevel: Int, currentStreak: Int) {
        self.profile = profile
        self.currentXP = currentXP
        self.currentLevel = currentLevel
        self.xpToNextLevel = xpToNextLevel
        self.currentStreak = currentStreak
        
        // Calculate progress (0.0 to 1.0)
        let xpInCurrentLevel = currentXP - AvatarService.xpForLevel(currentLevel)
        let xpNeededForLevel = AvatarService.xpForLevel(currentLevel + 1) - AvatarService.xpForLevel(currentLevel)
        self.progressToNextLevel = min(1.0, max(0.0, Double(xpInCurrentLevel) / Double(xpNeededForLevel)))
    }
}

// MARK: - Protocol

protocol AvatarServiceProtocol {
    func fetchAvatarData() async -> Result<AvatarData, AvatarError>
    func fetchUserXP() async -> Result<Int, AvatarError>
    func fetchCurrentStreak() async -> Result<Int, AvatarError>
    func uploadAvatar(imageData: Data, fileName: String, currentAvatarUrl: String?) async -> Result<String, AvatarError>
    func deleteAvatar(avatarUrl: String) async -> Result<Void, AvatarError>
    func uploadProfilePicture(imageData: Data, fileName: String, currentProfilePictureUrl: String?) async -> Result<String, AvatarError>
    func deleteProfilePicture(profilePictureUrl: String) async -> Result<Void, AvatarError>
}

// MARK: - Implementation

@MainActor
class AvatarService: AvatarServiceProtocol {
    @ObservationIgnored @Injected(\.appState) var appState
    
    init() {}
    
    private var isAuthenticated: Bool {
        return appState.isAuthenticated
    }
    
    private var currentProfile: Profile? {
        return appState.userAccountData?.profile
    }
    
    func fetchAvatarData() async -> Result<AvatarData, AvatarError> {
        guard isAuthenticated else {
            return .failure(.notAuthenticated)
        }
        
        guard let profile = currentProfile else {
            return .failure(.profileNotFound)
        }
        
        // Fetch user's total XP from workouts
        let xpResult = await fetchUserXP()
        let streakResult = await fetchCurrentStreak()
        
        switch (xpResult, streakResult) {
        case (.success(let totalXP), .success(let streak)):
            let currentLevel = Self.levelForXP(totalXP)
            let xpToNext = Self.xpForLevel(currentLevel + 1) - totalXP
            
            let avatarData = AvatarData(
                profile: profile,
                currentXP: totalXP,
                currentLevel: currentLevel,
                xpToNextLevel: xpToNext,
                currentStreak: streak
            )
            
            return .success(avatarData)
            
        case (.failure(let error), _):
            return .failure(error)
        case (_, .failure(let error)):
            return .failure(error)
        }
    }
    
    func fetchUserXP() async -> Result<Int, AvatarError> {
        guard isAuthenticated, let profile = currentProfile else {
            return .failure(.notAuthenticated)
        }
        
        do {
            // Sum all XP earned from workouts
            let workouts: [Workout] = try await client.from("workouts")
                .select()
                .eq("user_id", value: profile.id.uuidString)
                .execute()
                .value
            
            let totalXP = workouts.reduce(0) { $0 + $1.xpEarned }
            return .success(totalXP)
            
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func fetchCurrentStreak() async -> Result<Int, AvatarError> {
        guard isAuthenticated, let profile = currentProfile else {
            return .failure(.notAuthenticated)
        }
        
        do {
            // Get the streak from the streaks table
            let streak: UserStreak = try await client.from("streaks")
                .select()
                .eq("user_id", value: profile.id.uuidString)
                .single()
                .execute()
                .value
            
            // Check if the streak is still valid (workout within last 48 hours)
            if let lastWorkoutDate = streak.lastWorkoutDate {
                let calendar = Calendar.current
                let now = Date()
                let hoursSinceLastWorkout = calendar.dateComponents([.hour], from: lastWorkoutDate, to: now).hour ?? 0
                
                if hoursSinceLastWorkout > 48 {
                    // It's been more than 48 hours, streak is broken
                    return .success(0)
                }
            }
            
            return .success(streak.currentStreak)
        } catch {
            // If no streak record exists yet, return 0
            return .success(0)
        }
    }
    
    // MARK: - Level Calculation
    
    /// Calculate level based on total XP (100 XP per level)
    static func levelForXP(_ xp: Int) -> Int {
        return max(1, xp / 100 + 1)
    }
    
    /// Calculate XP required for a specific level
    static func xpForLevel(_ level: Int) -> Int {
        return max(0, (level - 1) * 100)
    }
    
    func uploadAvatar(imageData: Data, fileName: String, currentAvatarUrl: String? = nil) async -> Result<String, AvatarError> {
        guard isAuthenticated, let userId = client.auth.currentUser?.id else {
            return .failure(.notAuthenticated)
        }
        
        do {
            // Delete old avatar if it exists
            if let currentUrl = currentAvatarUrl, !currentUrl.isEmpty {
                let deleteResult = await deleteAvatar(avatarUrl: currentUrl)
                if case .failure(let error) = deleteResult {
                    print("⚠️ Warning: Failed to delete old avatar: \(error.localizedDescription)")
                    // Continue with upload even if delete fails
                }
            }
            
            let filePath = "avatars/\(userId.uuidString)/\(fileName)"
            
            // Upload image to avatar-images bucket
            let _ = try await client.storage
                .from("avatar-images")
                .upload(
                    filePath,
                    data: imageData,
                    options: FileOptions(
                        cacheControl: "3600",
                        upsert: true
                    )
                )
            
            // Get public URL
            let url = try client.storage
                .from("avatar-images")
                .getPublicURL(path: filePath)
            
            return .success(url.absoluteString)
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    func deleteAvatar(avatarUrl: String) async -> Result<Void, AvatarError> {
        guard isAuthenticated else {
            return .failure(.notAuthenticated)
        }
        
        do {
            // Extract file path from URL
            guard let filePath = extractFilePathFromAvatarUrl(avatarUrl) else {
                return .failure(.unknownError("Invalid avatar URL format"))
            }
            
            // Delete from storage
            try await client.storage
                .from("avatar-images")
                .remove(paths: [filePath])
            
            return .success(())
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    func uploadProfilePicture(imageData: Data, fileName: String, currentProfilePictureUrl: String? = nil) async -> Result<String, AvatarError> {
        guard isAuthenticated, let profile = currentProfile else {
            return .failure(.notAuthenticated)
        }
        
        do {
            // Delete old profile picture if it exists
            if let currentUrl = currentProfilePictureUrl, !currentUrl.isEmpty {
                let deleteResult = await deleteProfilePicture(profilePictureUrl: currentUrl)
                if case .failure(let error) = deleteResult {
                    print("⚠️ Warning: Failed to delete old profile picture: \(error.localizedDescription)")
                    // Continue with upload even if delete fails
                }
            }
            
            // Process image: downsize and compress
            guard let processedImageData = processProfilePictureImage(imageData) else {
                return .failure(.unknownError("Failed to process profile picture"))
            }
            
            let filePath = "profile-pictures/\(profile.id.uuidString)/\(fileName)"
            
            // Upload image to profile-pictures bucket
            let _ = try await client.storage
                .from("profile-pictures")
                .upload(
                    filePath,
                    data: processedImageData,
                    options: FileOptions(
                        cacheControl: "3600",
                        upsert: true
                    )
                )
            
            // Get public URL
            let url = try client.storage
                .from("profile-pictures")
                .getPublicURL(path: filePath)
            
            return .success(url.absoluteString)
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    func deleteProfilePicture(profilePictureUrl: String) async -> Result<Void, AvatarError> {
        guard isAuthenticated else {
            return .failure(.notAuthenticated)
        }
        
        do {
            // Extract file path from URL
            guard let filePath = extractFilePathFromUrl(profilePictureUrl, bucket: "profile-pictures") else {
                return .failure(.unknownError("Invalid profile picture URL format"))
            }
            
            // Delete from storage
            try await client.storage
                .from("profile-pictures")
                .remove(paths: [filePath])
            
            return .success(())
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    private func processProfilePictureImage(_ imageData: Data) -> Data? {
        guard let uiImage = UIImage(data: imageData) else { return nil }
        
        // Resize to appropriate profile picture size (e.g., 300x300)
        let targetSize = CGSize(width: 300, height: 300)
        let resizedImage = resizeImage(uiImage, to: targetSize)
        
        // Compress to JPEG with 0.8 quality to reduce file size
        return resizedImage.jpegData(compressionQuality: 0.8)
    }
    
    private func resizeImage(_ image: UIImage, to targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    private func extractFilePathFromAvatarUrl(_ url: String) -> String? {
        return extractFilePathFromUrl(url, bucket: "avatar-images")
    }
    
    private func extractFilePathFromUrl(_ url: String, bucket: String) -> String? {
        // Extract the file path from a Supabase storage URL
        // URL format: https://[project].supabase.co/storage/v1/object/public/[bucket]/[path]
        guard let range = url.range(of: "/\(bucket)/") else {
            return nil
        }
        let pathStart = url.index(range.upperBound, offsetBy: 0)
        return String(url[pathStart...])
    }
}

// MARK: - Mock Service

@MainActor
class MockAvatarService: AvatarServiceProtocol {
    var shouldFail = false
    var mockTotalXP = 1250
    var mockStreak = 14
    
    private let mockProfile = Profile(
        id: UUID(),
        firstName: "William",
        lastName: "Vengeance", 
        avatarName: "William Vengeance",
        credits: 150
    )
    
    func fetchAvatarData() async -> Result<AvatarData, AvatarError> {
        if shouldFail {
            return .failure(.unknownError("Mock avatar data fetch failed"))
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        let currentLevel = AvatarService.levelForXP(mockTotalXP)
        let xpToNext = AvatarService.xpForLevel(currentLevel + 1) - mockTotalXP
        
        let avatarData = AvatarData(
            profile: mockProfile,
            currentXP: mockTotalXP,
            currentLevel: currentLevel,
            xpToNextLevel: xpToNext,
            currentStreak: mockStreak
        )
        
        return .success(avatarData)
    }
    
    func fetchUserXP() async -> Result<Int, AvatarError> {
        if shouldFail {
            return .failure(.unknownError("Mock XP fetch failed"))
        }
        return .success(mockTotalXP)
    }
    
    func fetchCurrentStreak() async -> Result<Int, AvatarError> {
        if shouldFail {
            return .failure(.unknownError("Mock streak fetch failed"))
        }
        return .success(mockStreak)
    }
    
    func uploadAvatar(imageData: Data, fileName: String, currentAvatarUrl: String? = nil) async -> Result<String, AvatarError> {
        if shouldFail {
            return .failure(.unknownError("Mock avatar upload failed"))
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Return mock URL
        return .success("https://mock-storage.com/avatars/\(UUID().uuidString)/\(fileName)")
    }
    
    func deleteAvatar(avatarUrl: String) async -> Result<Void, AvatarError> {
        if shouldFail {
            return .failure(.unknownError("Mock avatar deletion failed"))
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
        
        return .success(())
    }
    
    func uploadProfilePicture(imageData: Data, fileName: String, currentProfilePictureUrl: String? = nil) async -> Result<String, AvatarError> {
        if shouldFail {
            return .failure(.unknownError("Mock profile picture upload failed"))
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Return mock URL
        return .success("https://mock-storage.com/profile-pictures/\(UUID().uuidString)/\(fileName)")
    }
    
    func deleteProfilePicture(profilePictureUrl: String) async -> Result<Void, AvatarError> {
        if shouldFail {
            return .failure(.unknownError("Mock profile picture deletion failed"))
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
        
        return .success(())
    }
}
