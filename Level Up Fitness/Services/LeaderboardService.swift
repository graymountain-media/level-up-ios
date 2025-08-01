import Foundation
import Supabase

// MARK: - Error Types

enum LeaderboardError: LocalizedError {
    case notAuthenticated
    case networkError(String)
    case databaseError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to view the leaderboard"
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

// MARK: - Protocol

protocol LeaderboardServiceProtocol {
    func fetchLeaderboard() async -> Result<[any LeaderboardEntry], LeaderboardError>
    func fetchStreakLeaderboard() async -> Result<[any LeaderboardEntry], LeaderboardError>
    func getCurrentUserRank() async -> Result<Int?, LeaderboardError>
}

// MARK: - Implementation

@MainActor
class LeaderboardService: LeaderboardServiceProtocol {
    private let appState: AppState
    private let client: SupabaseClient
    
    init(appState: AppState) {
        self.appState = appState
        self.client = appState.supabaseClient
    }
    
    var userDataService: UserDataService {
        appState.userDataService
    }
    
    private var isAuthenticated: Bool {
        return appState.isAuthenticated
    }
    
    private var currentUserId: UUID? {
        return appState.supabaseClient.auth.currentUser?.id
    }
    
    func fetchLeaderboard() async -> Result<[any LeaderboardEntry], LeaderboardError> {
        guard isAuthenticated else {
            return .failure(.notAuthenticated)
        }
        
        do {
            let entries: [XpLeaderboardEntry] = try await client
                .rpc("get_leaderboard")
                .limit(100)
                .execute()
                .value
            
            return .success(entries)
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func fetchStreakLeaderboard() async -> Result<[any LeaderboardEntry], LeaderboardError> {
        guard isAuthenticated else {
            return .failure(.notAuthenticated)
        }
        
        do {
            let entries: [StreakLeaderboardEntry] = try await client
                .rpc("get_streak_leaderboard")
                .limit(100)
                .execute()
                .value
            
            return .success(entries)
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func getCurrentUserRank() async -> Result<Int?, LeaderboardError> {
        guard isAuthenticated, let userId = currentUserId else {
            return .failure(.notAuthenticated)
        }
        
        let leaderboardResult = await fetchLeaderboard()
        
        switch leaderboardResult {
        case .success(let entries):
            let rank = entries.firstIndex(where: { $0.userId == userId })
            return .success(rank != nil ? rank! + 1 : nil) // Convert to 1-based ranking
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - Mock Service

class MockLeaderboardService: LeaderboardServiceProtocol {
    var shouldFail = false
    var mockEntries: [any LeaderboardEntry] = XpLeaderboardEntry.testData
    var mockUserRank: Int? = 4
    
    func fetchLeaderboard() async -> Result<[any LeaderboardEntry], LeaderboardError> {
        if shouldFail {
            return .failure(.unknownError("Mock leaderboard fetch failed"))
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        return .success(mockEntries)
    }
    
    func fetchStreakLeaderboard() async -> Result<[any LeaderboardEntry], LeaderboardError> {
        if shouldFail {
            return .failure(.unknownError("Mock leaderboard fetch failed"))
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        return .success(mockEntries)
    }
    
    func getCurrentUserRank() async -> Result<Int?, LeaderboardError> {
        if shouldFail {
            return .failure(.unknownError("Mock rank fetch failed"))
        }
        
        return .success(mockUserRank)
    }
}
