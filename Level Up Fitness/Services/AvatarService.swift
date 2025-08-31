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

struct AvatarAsset: Codable, Identifiable {
    let id: UUID
    let styleNumber: Int
    let typeAProfileImageUrl: String
    let typeAFullBodyImageUrl: String
    let typeBProfileImageUrl: String
    let typeBFullBodyImageUrl: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case styleNumber = "style_number"
        case typeAProfileImageUrl = "type_a_profile_image_url"
        case typeAFullBodyImageUrl = "type_a_full_body_image_url"
        case typeBProfileImageUrl = "type_b_profile_image_url"
        case typeBFullBodyImageUrl = "type_b_full_body_image_url"
        case createdAt = "created_at"
    }
    
    func profileImageUrl(for type: AvatarType) -> String {
        switch type {
        case .typeA:
            return typeAProfileImageUrl
        case .typeB:
            return typeBProfileImageUrl
        }
    }
    
    func fullBodyImageUrl(for type: AvatarType) -> String {
        switch type {
        case .typeA:
            return typeAFullBodyImageUrl
        case .typeB:
            return typeBFullBodyImageUrl
        }
    }
}

// MARK: - Protocol

protocol AvatarServiceProtocol {
    func fetchAvatarData() async -> Result<AvatarData, AvatarError>
    func fetchUserXP() async -> Result<Int, AvatarError>
    func fetchCurrentStreak() async -> Result<Int, AvatarError>
    func fetchAvatarAssets() async -> Result<[AvatarAsset], AvatarError>
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
    
    func fetchAvatarAssets() async -> Result<[AvatarAsset], AvatarError> {
        do {
            let avatarAssets: [AvatarAsset] = try await client.from("avatar_assets")
                .select()
                .order("style_number")
                .execute()
                .value
            
            return .success(avatarAssets)
        } catch {
            return .failure(.databaseError(error.localizedDescription))
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
            
            // Process image: downsize and compress
            guard let processedImageData = processAvatarPictureImage(imageData) else {
                return .failure(.unknownError("Failed to process avatar picture"))
            }
            
            let filePath = "avatars/\(userId.uuidString)/\(fileName)"
            
            // Upload image to avatar-images bucket
            let _ = try await client.storage
                .from("avatar-images")
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
    
    private func processAvatarPictureImage(_ imageData: Data) -> Data? {
        guard let uiImage = UIImage(data: imageData) else { return nil }
        
        return uiImage.compress(to: 600)
    }
    
    private func processProfilePictureImage(_ imageData: Data) -> Data? {
        guard let uiImage = UIImage(data: imageData) else { return nil }
        
        return uiImage.compress(to: 300)
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
        avatarName: "Striker",
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
    
    func fetchAvatarAssets() async -> Result<[AvatarAsset], AvatarError> {
        if shouldFail {
            return .failure(.unknownError("Mock avatar assets fetch failed"))
        }
        
        // Return mock avatar assets
        let mockAssets = [
            AvatarAsset(
                id: UUID(),
                styleNumber: 1,
                typeAProfileImageUrl: "https://mock-storage.com/avatars/profiles/style_1_A.png",
                typeAFullBodyImageUrl: "https://mock-storage.com/avatars/full_body/style_1_A.png",
                typeBProfileImageUrl: "https://mock-storage.com/avatars/profiles/style_1_B.png",
                typeBFullBodyImageUrl: "https://mock-storage.com/avatars/full_body/style_1_B.png",
                createdAt: Date()
            ),
            AvatarAsset(
                id: UUID(),
                styleNumber: 2,
                typeAProfileImageUrl: "https://mock-storage.com/avatars/profiles/style_2_A.png",
                typeAFullBodyImageUrl: "https://mock-storage.com/avatars/full_body/style_2_A.png",
                typeBProfileImageUrl: "https://mock-storage.com/avatars/profiles/style_2_B.png",
                typeBFullBodyImageUrl: "https://mock-storage.com/avatars/full_body/style_2_B.png",
                createdAt: Date()
            ),
        ]
        
        return .success(mockAssets)
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


extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let newSize = CGSize(width: size.width * percentage, height: size.height * percentage)

        return self.preparingThumbnail(of: newSize)
    }

    func compress(to kb: Int, allowedMargin: CGFloat = 0.2) -> Data? {
        let bytes = kb * 1024
        let threshold = Int(CGFloat(bytes) * (1 + allowedMargin))
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.05
        var holderImage = self
        while let data = holderImage.pngData() {
            let ratio = data.count / bytes
            if data.count < threshold {
                return data
            } else {
                let multiplier = CGFloat((ratio / 5) + 1)
                compression -= (step * multiplier)

                guard let newImage = self.resized(withPercentage: compression) else { break }
                holderImage = newImage
            }
        }

        return nil
    }
}
