//
//  StreakLeaderboardEntry.swift
//  Level Up
//
//  Created by Jake Gray on 8/25/25.
//

import Foundation

struct StreakLeaderboardEntry: LeaderboardEntry {
    let userId: UUID
    let currentStreak: Int
    let avatarName: String?
    var profilePictureURL: String? = nil
    var heroPath: HeroPath? = nil
    var faction: Faction? = nil
    let rank: Int
    
    var id: UUID { userId }
    var value: Int { currentStreak }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case currentStreak = "current_streak"
        case avatarName = "avatar_name"
        case profilePictureURL = "profile_picture_url"
        case heroPath = "hero_path"
        case faction
        case rank
    }
    
    static let testData: [any LeaderboardEntry] = []
//    [
//        StreakLeaderboardEntry(
//            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
//            currentStreak: 10,
//            avatarName: "STRIKER",
//            rank: 1
//        ),
//        StreakLeaderboardEntry(
//            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
//            currentStreak: 9,
//            avatarName: "NYLA_X",
//            rank: 2
//        ),
//        StreakLeaderboardEntry(
//            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
//            currentStreak: 8,
//            avatarName: "FENRIR",
//            rank: 3
//        ),
//        StreakLeaderboardEntry(
//            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
//            currentStreak: 7,
//            avatarName: "KORVUS",
//            rank: 4
//        ),
//        StreakLeaderboardEntry(
//            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
//            currentStreak: 6,
//            avatarName: "VIPER",
//            rank: 5
//        )
//    ]
    
    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<StreakLeaderboardEntry.CodingKeys> = try decoder.container(keyedBy: StreakLeaderboardEntry.CodingKeys.self)
        
        self.userId = try container.decode(UUID.self, forKey: StreakLeaderboardEntry.CodingKeys.userId)
        self.currentStreak = try container.decode(Int.self, forKey: StreakLeaderboardEntry.CodingKeys.currentStreak)
        self.avatarName = try container.decodeIfPresent(String.self, forKey: StreakLeaderboardEntry.CodingKeys.avatarName)
        self.profilePictureURL = try container.decodeIfPresent(String.self, forKey: StreakLeaderboardEntry.CodingKeys.profilePictureURL)
        self.faction = try container.decodeIfPresent(Faction.self, forKey: StreakLeaderboardEntry.CodingKeys.faction)
        self.rank = try container.decode(Int.self, forKey: StreakLeaderboardEntry.CodingKeys.rank)
        
    }
}
