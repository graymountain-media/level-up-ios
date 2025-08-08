//
//  LeaderboardViewModel.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/18/25.
//

import Foundation
import Combine
import Supabase
import FactoryKit

protocol LeaderboardEntry: Identifiable, Decodable {
    var userId: UUID { get }
    var value: Int { get }
    var avatarName: String? { get }
    var rank: Int { get }
    var id: UUID { get }
}

struct XpLeaderboardEntry: LeaderboardEntry {
    let userId: UUID
    let xp: Int
    let currentLevel: Int
    let avatarName: String?
    let rank: Int
    
    var id: UUID { userId }
    var value: Int { xp }
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case xp
        case currentLevel = "current_level"
        case avatarName = "avatar_name"
        case rank
    }
    
    static let testData: [any LeaderboardEntry] = [
        XpLeaderboardEntry(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            xp: 5000,
            currentLevel: 10,
            avatarName: "STRIKER",
            rank: 1
        ),
        XpLeaderboardEntry(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            xp: 4500,
            currentLevel: 9,
            avatarName: "NYLA_X",
            rank: 2
        ),
        XpLeaderboardEntry(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            xp: 3800,
            currentLevel: 8,
            avatarName: "FENRIR",
            rank: 3
        ),
        XpLeaderboardEntry(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            xp: 3200,
            currentLevel: 7,
            avatarName: "KORVUS",
            rank: 4
        ),
        XpLeaderboardEntry(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            xp: 2800,
            currentLevel: 6,
            avatarName: "VIPER",
            rank: 5
        )
    ]
}

struct StreakLeaderboardEntry: LeaderboardEntry {
    let userId: UUID
    let currentStreak: Int
    let avatarName: String?
    let rank: Int
    
    var id: UUID { userId }
    var value: Int { currentStreak }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case currentStreak = "current_streak"
        case avatarName = "avatar_name"
        case rank
    }
    
    static let testData: [any LeaderboardEntry] = [
        StreakLeaderboardEntry(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            currentStreak: 10,
            avatarName: "STRIKER",
            rank: 1
        ),
        StreakLeaderboardEntry(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            currentStreak: 9,
            avatarName: "NYLA_X",
            rank: 2
        ),
        StreakLeaderboardEntry(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            currentStreak: 8,
            avatarName: "FENRIR",
            rank: 3
        ),
        StreakLeaderboardEntry(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            currentStreak: 7,
            avatarName: "KORVUS",
            rank: 4
        ),
        StreakLeaderboardEntry(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            currentStreak: 6,
            avatarName: "VIPER",
            rank: 5
        )
    ]
}

struct FactionLeaderboardEntry: LeaderboardEntry {
    let faction: Faction
    let totalXp: Int
    let memberCount: Int
    let topPlayerName: String
    let topPlayerXp: Int
    let rank: Int
    
    // Conform to LeaderboardEntry protocol
    var userId: UUID { UUID() } // Not applicable for factions, but required
    var value: Int { totalXp }
    var avatarName: String? { topPlayerName }
    var id: UUID { UUID() }
    
    enum CodingKeys: String, CodingKey {
        case faction
        case totalXp = "total_xp"
        case memberCount = "member_count"
        case topPlayerName = "top_player_name"
        case topPlayerXp = "top_player_xp"
        case rank
    }
    
    init(faction: Faction, totalXp: Int, memberCount: Int, topPlayerName: String, topPlayerXp: Int, rank: Int) {
        self.faction = faction
        self.totalXp = totalXp
        self.memberCount = memberCount
        self.topPlayerName = topPlayerName
        self.topPlayerXp = topPlayerXp
        self.rank = rank
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalXp = try container.decode(Int.self, forKey: .totalXp)
        memberCount = try container.decode(Int.self, forKey: .memberCount)
        topPlayerName = try container.decode(String.self, forKey: .topPlayerName)
        topPlayerXp = try container.decode(Int.self, forKey: .topPlayerXp)
        rank = try container.decode(Int.self, forKey: .rank)
        
        // Convert string to Faction enum
        let factionString = try container.decode(String.self, forKey: .faction)
        faction = Faction.fromString(factionString) ?? .echoreach
    }

}

@MainActor
@Observable
class LeaderboardViewModel {
    // MARK: - Properties
    @ObservationIgnored @Injected(\.leaderboardService) var leaderboardService
    
    // State properties
    var leaderboardEntries: [any LeaderboardEntry] = []
    var isLoading = true
    var errorMessage: String?
    var showError = false
    var currentUserRank: Int?
    
    // MARK: - Public Methods
    
    /// Fetches the leaderboard data
    func fetchLeaderboard(for tab: LeaderboardTab) async {
        isLoading = true
        errorMessage = nil
        showError = false
        
        var result: Result<[any LeaderboardEntry], LeaderboardError>
        switch tab {
        case .xp:
            result = await leaderboardService.fetchLeaderboard()
        case .streaks:
            result = await leaderboardService.fetchStreakLeaderboard()
        case .factions:
            result = await leaderboardService.fetchFactionLeaderboard()
        }
        
        switch result {
        case .success(let entries):
            await MainActor.run {
                self.leaderboardEntries = entries
                self.isLoading = false
            }
            
        case .failure(let error):
            setError("Failed to load leaderboard: \(error.localizedDescription)")
        }
    }
    
    /// Fetches the current user's rank on the leaderboard
    func fetchCurrentUserRank() async {
        let result = await leaderboardService.getCurrentUserRank()
        
        switch result {
        case .success(let rank):
            await MainActor.run {
                self.currentUserRank = rank
            }
        case .failure(let error):
            print("Failed to fetch user rank: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Sets an error message and shows the error alert
    /// - Parameter message: Error message to display
    private func setError(_ message: String) {
        Task { @MainActor in
            isLoading = false
            errorMessage = message
            showError = true
        }
    }
}
