//
//  MockUserDataService.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/28/25.
//

import Foundation
import Supabase

class MockUserDataService: UserDataServiceProtocol {
    var shouldFail = false
    var mockXpInfo = UserXPInfo(xp: 1250, currentLevel: 17)
    var mockStreak = 14
    
    private let mockProfile = Profile(
        id: UUID(),
        firstName: "William",
        lastName: "Vengeance",
        avatarName: "William Vengeance",
        credits: 150
    )
    
    // Mock level info data that matches the screenshot
    private let mockLevelInfo: [LevelInfo] = [
        LevelInfo(level: 1, xpToReach: 0, cumulativeXP: 0),
        LevelInfo(level: 2, xpToReach: 20, cumulativeXP: 20),
        LevelInfo(level: 3, xpToReach: 55, cumulativeXP: 75),
        LevelInfo(level: 4, xpToReach: 58, cumulativeXP: 133),
        LevelInfo(level: 5, xpToReach: 61, cumulativeXP: 194),
        LevelInfo(level: 6, xpToReach: 64, cumulativeXP: 258),
        LevelInfo(level: 7, xpToReach: 68, cumulativeXP: 326),
        LevelInfo(level: 8, xpToReach: 71, cumulativeXP: 397),
        LevelInfo(level: 9, xpToReach: 74, cumulativeXP: 471),
        LevelInfo(level: 10, xpToReach: 77, cumulativeXP: 548),
        LevelInfo(level: 11, xpToReach: 81, cumulativeXP: 629),
        LevelInfo(level: 12, xpToReach: 84, cumulativeXP: 713),
        LevelInfo(level: 13, xpToReach: 87, cumulativeXP: 800),
        LevelInfo(level: 14, xpToReach: 90, cumulativeXP: 890),
        LevelInfo(level: 15, xpToReach: 94, cumulativeXP: 984),
        LevelInfo(level: 16, xpToReach: 97, cumulativeXP: 1081),
        LevelInfo(level: 17, xpToReach: 100, cumulativeXP: 1181),
        LevelInfo(level: 18, xpToReach: 103, cumulativeXP: 1284),
        LevelInfo(level: 19, xpToReach: 106, cumulativeXP: 1390),
        LevelInfo(level: 20, xpToReach: 110, cumulativeXP: 1500)
    ]
    
    func fetchUserAccountData() async -> Result<UserAccountData, UserDataError> {
        if shouldFail {
            return .failure(.unknownError("Mock user data fetch failed"))
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        let currentLevelInfo = UserDataService.calculateLevelInfo(xpInfo: mockXpInfo, levelInfo: mockLevelInfo)
        let accountData = await UserAccountData(
            profile: mockProfile,
            totalXP: mockXpInfo.xp,
            currentLevel: mockXpInfo.currentLevel,
            currentStreak: mockStreak,
            xpToNextLevel: currentLevelInfo.xpToNextLevel,
            progressToNextLevel: currentLevelInfo.progressToNextLevel
        )
        
        return .success(accountData)
    }
    
    func fetchXpInfo() async throws -> UserXPInfo {
        if shouldFail {
            throw UserDataError.unknownError("Mock XP fetch failed")
        }
        return mockXpInfo
    }
    
    func fetchCurrentStreak() async throws -> Int {
        if shouldFail {
            throw UserDataError.unknownError("Mock streak fetch failed")
        }
        return mockStreak
    }
    
    func fetchLevelInfo() async throws -> [LevelInfo] {
        if shouldFail {
            throw UserDataError.unknownError("Mock level info fetch failed")
        }
        return mockLevelInfo
    }
    
    func refreshUserData() async -> Result<UserAccountData, UserDataError> {
        return await fetchUserAccountData()
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String) async -> Result<Void, Error> {
        if shouldFail {
            return .failure(NSError(domain: "MockUserDataService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock signup failed"]))
        }
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
        return .success(())
    }
    
    func signIn(email: String, password: String) async -> Result<Void, Error> {
        if shouldFail {
            return .failure(NSError(domain: "MockUserDataService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock signin failed"]))
        }
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
        return .success(())
    }
    
    func signOut() async -> Result<Void, Error> {
        if shouldFail {
            return .failure(NSError(domain: "MockUserDataService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock signout failed"]))
        }
        return .success(())
    }
    
    func resetPassword(email: String) async -> Result<Void, Error> {
        if shouldFail {
            return .failure(NSError(domain: "MockUserDataService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock password reset failed"]))
        }
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
        return .success(())
    }
    
    func checkExistingSession() async -> Result<Session?, UserDataError> {
        if shouldFail {
            return .failure(.unknownError("Mock session check failed"))
        }
        // Mock having a valid session
        return .success(nil) // Return nil for now as we don't have a real session
    }
    
    func getAuthStateChanges() -> AsyncStream<(AuthChangeEvent, Session?)> {
        return AsyncStream { continuation in
            // Mock stream that doesn't emit any changes
            continuation.finish()
        }
    }
    
    func createProfile(firstName: String, lastName: String, avatarName: String) async -> Result<Void, Error> {
        if shouldFail {
            return .failure(NSError(domain: "MockUserDataService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock profile creation failed"]))
        }
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
        return .success(())
    }
    
    func updateProfile(firstName: String, lastName: String, avatarName: String) async -> Result<Void, Error> {
        if shouldFail {
            return .failure(NSError(domain: "MockUserDataService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock profile update failed"]))
        }
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
        return .success(())
    }
}
