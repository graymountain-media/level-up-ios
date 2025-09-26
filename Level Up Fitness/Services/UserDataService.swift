import Foundation
import Supabase
import Combine
import FactoryKit

class Profile: Codable, Identifiable {
    let id: UUID
    var firstName: String
    var lastName: String
    var avatarName: String
    var avatarUrl: String?
    var profilePictureUrl: String?
    var credits: Int
    var faction: Faction?
    var path: HeroPath?
    
    init(id: UUID, firstName: String, lastName: String, avatarName: String, avatarUrl: String? = nil, profilePictureUrl: String? = nil, credits: Int = 0, faction: Faction? = nil, path: HeroPath? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.avatarName = avatarName
        self.avatarUrl = avatarUrl
        self.profilePictureUrl = profilePictureUrl
        self.credits = credits
        self.faction = faction
        self.path = path
    }

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarName = "avatar_name"
        case avatarUrl = "avatar_image_url"
        case profilePictureUrl = "profile_picture_url"
        case credits
        case faction
        case path = "hero_path"
    }
    
    // Custom decoding to convert string to Faction enum
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        avatarName = try container.decode(String.self, forKey: .avatarName)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        profilePictureUrl = try container.decodeIfPresent(String.self, forKey: .profilePictureUrl)
        credits = try container.decode(Int.self, forKey: .credits)
        
        // Convert string to Faction enum
        if let factionString = try container.decodeIfPresent(String.self, forKey: .faction) {
            faction = Faction.fromString(factionString)
        } else {
            faction = nil
        }
        
        // Decode Path directly (it's already Codable)
        path = try container.decodeIfPresent(HeroPath.self, forKey: .path)
    }
    
    // Custom encoding to convert Faction enum to string
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(avatarName, forKey: .avatarName)
        try container.encodeIfPresent(avatarUrl, forKey: .avatarUrl)
        try container.encodeIfPresent(profilePictureUrl, forKey: .profilePictureUrl)
        try container.encode(credits, forKey: .credits)
        
        // Convert Faction enum to string
        if let faction = faction {
            try container.encode(faction.name.lowercased(), forKey: .faction)
        } else {
            try container.encodeNil(forKey: .faction)
        }
        
        // Encode Path directly (it's already Codable)
        try container.encodeIfPresent(path, forKey: .path)
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

// MARK: - Faction Leaderboard Models

struct FactionLeaderboard: Decodable {
    let faction: Faction
    let memberCount: Int
    let totalXp: Int
    let avgXp: Double
    let topPlayer: FactionTopPlayer?
    
    private enum CodingKeys: String, CodingKey {
        case faction
        case memberCount = "member_count"
        case totalXp = "total_xp"
        case avgXp = "avg_xp"
        case topPlayer = "top_player"
    }
}

struct FactionTopPlayer: Codable {
    let id: UUID
    let name: String
    let xp: Int
    let currentLevel: Int
    
    private enum CodingKeys: String, CodingKey {
        case id, name, xp
        case currentLevel = "current_level"
    }
}

// MARK: - Protocol

protocol UserDataServiceProtocol {
    // Authentication methods  
    func signUp(email: String, password: String) async -> Result<Void, Error>
    func signIn(email: String, password: String) async -> Result<Void, Error>
    func signOut() async -> Result<Void, Error>
    func resetPassword(email: String) async -> Result<Void, Error>
    func updatePassword(newPassword: String) async -> Result<Void, Error>
    func checkExistingSession() async -> Result<Session?, UserDataError>
    func getAuthStateChanges() -> AsyncStream<(AuthChangeEvent, Session?)>
    
    // Profile and user data methods (fetchCurrentProfile combined into fetchUserAccountData)
    func fetchUserAccountData() async -> Result<UserAccountData, UserDataError>
    func createProfile(firstName: String, lastName: String, avatarName: String, avatarUrl: String?, profilePictureUrl: String?) async -> Result<Void, Error>
    func updateProfile(firstName: String, lastName: String, avatarName: String, avatarUrl: String?, profilePictureUrl: String?) async -> Result<Void, Error>
    func updateFaction(_ faction: Faction) async -> Result<Void, Error>
    func refreshUserData() async -> Result<UserAccountData, UserDataError>
    
    // Individual data fetching methods
    func fetchXpInfo() async throws -> UserXPInfo
    func fetchCurrentStreak() async throws -> Int
    func fetchLevelInfo() async throws -> [LevelInfo]
    
    // Faction leaderboard methods
    func fetchFactionLeaderboards() async throws -> [FactionLeaderboard]
    
    // Path methods
    func fetchWorkoutTypeStats(for userId: UUID) async throws -> WorkoutTypeStats
    
}

class UserDataService: UserDataServiceProtocol {
    @Injected(\.trackingService) private var tracking: TrackingProtocol

    // MARK: - Initialization

    init() {}
    
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
    
    func updatePassword(newPassword: String) async -> Result<Void, Error> {
        do {
            try await client.auth.update(user: UserAttributes(password: newPassword))
            
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Profile Management
    
    func createProfile(firstName: String, lastName: String, avatarName: String, avatarUrl: String? = nil, profilePictureUrl: String? = nil) async -> Result<Void, Error> {
        do {
            let userId = try await client.auth.session.user.id
            let newProfile = Profile(id: userId, firstName: firstName, lastName: lastName, avatarName: avatarName, avatarUrl: avatarUrl, profilePictureUrl: profilePictureUrl, credits: 0, faction: nil)
            
            try await client.from("profiles")
                .upsert(newProfile)
                .execute()
            
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func updateProfile(firstName: String, lastName: String, avatarName: String, avatarUrl: String? = nil, profilePictureUrl: String? = nil) async -> Result<Void, Error> {
        do {
            let userId = try await client.auth.session.user.id
            
            // First get current profile to preserve credits
            let currentProfile: Profile = try await client.from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            let updatedProfile = Profile(id: userId, firstName: firstName, lastName: lastName, avatarName: avatarName, avatarUrl: avatarUrl ?? currentProfile.avatarUrl, profilePictureUrl: profilePictureUrl ?? currentProfile.profilePictureUrl, credits: currentProfile.credits, faction: currentProfile.faction)
            
            try await client.from("profiles")
                .update(updatedProfile)
                .eq("id", value: userId)
                .execute()
            
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func updateFaction(_ faction: Faction) async -> Result<Void, Error> {
        do {
            let userId = try await client.auth.session.user.id

            try await client.from("profiles")
                .update(["faction": faction.name.lowercased()])
                .eq("id", value: userId)
                .execute()

            // Track faction selection
            tracking.track(.factionJoined(faction: faction.name.lowercased()))

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
            let daysSinceLastWorkout = calendar.dateComponents([.day], from: lastWorkoutDate, to: now).day ?? 0
            
            if daysSinceLastWorkout > 2 {
                // It's been more than 2 days, streak is broken
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
            // Fetch all required data concurrently
            async let xpInfo = fetchXpInfo()
            async let currentStreak = fetchCurrentStreak()
            async let levelInfo = fetchLevelInfo()
            
            // Await all concurrent operations
            let xpResult = try await xpInfo
            let streakResult = try await currentStreak
            let levelResult = try await levelInfo
            let currentLevelInfo = UserDataService.calculateLevelInfo(xpInfo: xpResult, levelInfo: levelResult)
            
            let userAccountData = await UserAccountData(
                profile: profile,
                totalXP: xpResult.xp,
                currentLevel: xpResult.currentLevel,
                currentStreak: streakResult,
                xpToNextLevel: currentLevelInfo.xpToNextLevel,
                progressToNextLevel: currentLevelInfo.progressToNextLevel
            )

            // Update tracking with latest user data
            tracking.identifyUser(
                userId: userId.uuidString,
                faction: profile.faction?.name.lowercased(),
                heroPath: profile.path?.name.lowercased(),
                level: xpResult.currentLevel,
                xpTotal: xpResult.xp,
                streakDays: streakResult
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
    
    // MARK: - Faction Leaderboard Methods
    
    func fetchFactionLeaderboards() async throws -> [FactionLeaderboard] {
        let leaderboards: [FactionLeaderboard] = try await client
            .from("faction_leaderboards")
            .select()
            .order("total_xp", ascending: false)
            .execute()
            .value
        
        return leaderboards
    }
    
    // MARK: - Path Methods
    
    func fetchWorkoutTypeStats(for userId: UUID) async throws -> WorkoutTypeStats {
        struct DatabaseStats: Codable {
            let strengthPercentage: Double
            let cardioPercentage: Double
            let functionalPercentage: Double
            let totalWorkouts: Int
            
            private enum CodingKeys: String, CodingKey {
                case strengthPercentage = "strength_percentage"
                case cardioPercentage = "cardio_percentage"
                case functionalPercentage = "functional_percentage"
                case totalWorkouts = "total_workouts"
            }
        }
        
        let result: DatabaseStats = try await client
            .rpc("get_user_workout_type_stats", params: ["user_id_param": userId])
            .single()
            .execute()
            .value
        
        return WorkoutTypeStats(
            strengthPercentage: result.strengthPercentage,
            cardioPercentage: result.cardioPercentage,
            functionalPercentage: result.functionalPercentage,
            totalWorkouts: result.totalWorkouts
        )
    }
    
}


