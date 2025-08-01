import Foundation
import Supabase
import Combine

class Profile: Codable, Identifiable {
    let id: UUID
    var firstName: String
    var lastName: String
    var avatarName: String
    var avatarUrl: String?
    var credits: Int
    
    init(id: UUID, firstName: String, lastName: String, avatarName: String, avatarUrl: String? = nil, credits: Int = 0) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.avatarName = avatarName
        self.avatarUrl = avatarUrl
        self.credits = credits
    }

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarName = "avatar_name"
        case avatarUrl = "avatar_image_url"
        case credits
    }
}

enum AuthState {
    case loading
    case authenticated(hasCompletedOnboarding: Bool)
    case unauthenticated
    case error(Error)
}

enum UserDataError: LocalizedError {
    case notAuthenticated
    case profileNotFound
    case networkError(String)
    case databaseError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to access user data"
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

struct LevelInfo: Codable {
    let level: Int
    let xpToReach: Int
    let cumulativeXP: Int
    
    enum CodingKeys: String, CodingKey {
        case level
        case xpToReach = "xp_to_reach"
        case cumulativeXP = "cumulative_xp"
    }
}

struct UserXPInfo: Codable {
    let xp: Int
    let currentLevel: Int
    
    private enum CodingKeys: String, CodingKey {
        case xp
        case currentLevel = "current_level"
    }
    
    init(xp: Int, currentLevel: Int) {
        self.xp = xp
        self.currentLevel = currentLevel
    }
}

@MainActor
struct UserAccountData {
    let profile: Profile
    let totalXP: Int
    let currentLevel: Int
    let xpToNextLevel: Int
    let progressToNextLevel: Double
    let currentStreak: Int
    
    init(profile: Profile, totalXP: Int, currentLevel: Int, currentStreak: Int, xpToNextLevel: Int, progressToNextLevel: Double) {
        self.profile = profile
        self.totalXP = totalXP
        self.currentLevel = currentLevel
        self.currentStreak = currentStreak
        self.xpToNextLevel = xpToNextLevel
        self.progressToNextLevel = progressToNextLevel
    }
    
    // Convenience computed properties
    var displayName: String {
        return "\(profile.firstName) \(profile.lastName)"
    }
    
    var avatarName: String {
        return profile.avatarName
    }
}

// MARK: - Protocol

protocol UserDataServiceProtocol {
    // Authentication methods  
    func signUp(email: String, password: String) async -> Result<Void, Error>
    func signIn(email: String, password: String) async -> Result<Void, Error>
    func signOut() async -> Result<Void, Error>
    func resetPassword(email: String) async -> Result<Void, Error>
    func checkExistingSession() async -> Result<Session?, UserDataError>
    func getAuthStateChanges() -> AsyncStream<(AuthChangeEvent, Session?)>
    
    // Profile and user data methods (fetchCurrentProfile combined into fetchUserAccountData)
    func fetchUserAccountData() async -> Result<UserAccountData, UserDataError>
    func createProfile(firstName: String, lastName: String, avatarName: String) async -> Result<Void, Error>
    func updateProfile(firstName: String, lastName: String, avatarName: String) async -> Result<Void, Error>
    func refreshUserData() async -> Result<UserAccountData, UserDataError>
    
    // Individual data fetching methods
    func fetchXpInfo() async throws -> UserXPInfo
    func fetchCurrentStreak() async throws -> Int
    func fetchLevelInfo() async throws -> [LevelInfo]
}

class UserDataService: UserDataServiceProtocol {
    let client: SupabaseClient
    
    // MARK: - Initialization
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    // MARK: - Authentication Methods
    
    func getAuthStateChanges() -> AsyncStream<(AuthChangeEvent, Session?)> {
        return AsyncStream { continuation in
            Task {
                for await (event, session) in client.auth.authStateChanges {
                    continuation.yield((event, session))
                }
                continuation.finish()
            }
        }
    }
    
    func checkExistingSession() async -> Result<Session?, UserDataError> {
        do {
            // Add timeout to prevent hanging on expired tokens
            let sessionTask = Task {
                try await client.auth.session
            }
            
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                throw NSError(domain: "UserDataService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Session check timeout"])
            }
            
            let session = try await withThrowingTaskGroup(of: Session.self) { group in
                group.addTask { try await sessionTask.value }
                group.addTask { _ = try await timeoutTask.value; throw NSError(domain: "UserDataService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Timeout"]) }
                
                let result = try await group.next()
                group.cancelAll()
                return result
            }
            
            return .success(session)
            
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String) async -> Result<Void, Error> {
        do {
            // Sign up the user with metadata
            let _ = try await client.auth.signUp(
                email: email,
                password: password,
                redirectTo: URL(string: "level-up-fitness://login-callback")
            )
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func signIn(email: String, password: String) async -> Result<Void, Error> {
        do {
            let _ = try await client.auth.signIn(
                email: email,
                password: password
            )
            

            
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func signOut() async -> Result<Void, Error> {
        do {
            try await client.auth.signOut()
            

            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func resetPassword(email: String) async -> Result<Void, Error> {
        do {
            try await client.auth.resetPasswordForEmail(email, redirectTo: URL(string: "level-up-fitness://reset-password"))
            
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Profile Management
    
    func createProfile(firstName: String, lastName: String, avatarName: String) async -> Result<Void, Error> {
        do {
            let userId = try await client.auth.session.user.id
            let newProfile = Profile(id: userId, firstName: firstName, lastName: lastName, avatarName: avatarName, credits: 0)
            
            try await client.from("profiles")
                .upsert(newProfile)
                .execute()
            
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func updateProfile(firstName: String, lastName: String, avatarName: String) async -> Result<Void, Error> {
        do {
            let userId = try await client.auth.session.user.id
            
            // First get current profile to preserve credits
            let currentProfile: Profile = try await client.from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            let updatedProfile = Profile(id: userId, firstName: firstName, lastName: lastName, avatarName: avatarName, credits: currentProfile.credits)
            
            try await client.from("profiles")
                .update(updatedProfile)
                .eq("id", value: userId)
                .execute()
            
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func fetchXpInfo() async throws -> UserXPInfo {
        let userId = try await client.auth.session.user.id
    
        // Sum all XP earned from workouts
        let userXPInfo: UserXPInfo = try await client.from("xp_levels")
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
        
        return userXPInfo
    }
    
    func fetchCurrentStreak() async throws -> Int {
        let userId = try await client.auth.session.user.id
    
        // Get the streak from the streaks table
        let streak: UserStreak = try await client.from("streaks")
            .select()
            .eq("user_id", value: userId.uuidString)
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
                return 0
            }
        }
        
        return streak.currentStreak
    }
    
    func fetchLevelInfo() async throws -> [LevelInfo] {
        let levelInfo: [LevelInfo] = try await client
            .from("level_info")
            .select()
            .order("level", ascending: true)
            .execute()
            .value
        
        return levelInfo
    }
    
    func fetchUserAccountData() async -> Result<UserAccountData, UserDataError> {
        do {
            let userId = try await client.auth.session.user.id
            // Fetch profile
            let profile: Profile? = try? await client.from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            guard let profile else {
                return .failure(.profileNotFound)
            }
            // Fetch all required data in parallel
            let xpInfo = try await fetchXpInfo()
            let currentStreak =  try await fetchCurrentStreak()
            let levelInfo = try await fetchLevelInfo()
            let currentLevelInfo = UserDataService.calculateLevelInfo(xpInfo: xpInfo, levelInfo: levelInfo)
            
            let userAccountData = await UserAccountData(
                profile: profile,
                totalXP: xpInfo.xp,
                currentLevel: xpInfo.currentLevel,
                currentStreak: currentStreak,
                xpToNextLevel: currentLevelInfo.xpToNextLevel,
                progressToNextLevel: currentLevelInfo.progressToNextLevel
            )
            
            return .success(userAccountData)
            
        } catch {
            if error.localizedDescription.contains("Invalid JWT") || error.localizedDescription.contains("expired") {
                return .failure(.notAuthenticated)
            }
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func refreshUserData() async -> Result<UserAccountData, UserDataError> {
        // This is the same as fetchUserAccountData but can be used for explicit refresh
        return await fetchUserAccountData()
    }
    
    // MARK: - Level Calculation Helpers
    
    /// Calculate level, XP to next level, and progress based on actual level table data
    static func calculateLevelInfo(xpInfo: UserXPInfo, levelInfo: [LevelInfo]) -> (xpToNextLevel: Int, progressToNextLevel: Double) {
        
        guard let currentLevelInfo = levelInfo.first(where: { $0.level == xpInfo.currentLevel + 1 }) else {
            return (0,0.0)
        }
        
        let xpToNextLevel = currentLevelInfo.cumulativeXP - xpInfo.xp
        let interval = currentLevelInfo.xpToReach
        let intervalProgress = Double(interval - xpToNextLevel) / Double(interval)
        return (xpToNextLevel, intervalProgress)
    }
    
    static func calculateNewLevel(currentXp: Int, levelInfo: [LevelInfo]) -> Int {
        guard let levelInfo = levelInfo.first(where: { $0.cumulativeXP > currentXp }) else {
            return -1
        }
        return levelInfo.level - 1
    }
}


