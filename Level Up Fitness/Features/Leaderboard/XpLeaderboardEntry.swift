//
//  XpLeaderboardEntry.swift
//  Level Up
//
//  Created by Jake Gray on 8/25/25.
//

import Foundation

struct XpLeaderboardEntry: LeaderboardEntry {
    let userId: UUID
    let xp: Int
    let currentLevel: Int
    let avatarName: String?
    var profilePictureURL: String? = nil
    var heroPath: HeroPath? = nil
    var faction: Faction? = nil
    let rank: Int
    
    var id: UUID { userId }
    var value: Int { xp }
    var level: Int { currentLevel }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case xp
        case currentLevel = "current_level"
        case avatarName = "avatar_name"
        case profilePictureURL = "profile_picture_url"
        case heroPath = "hero_path"
        case faction
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
            heroPath: .brute,
            faction: .echoreach,
            rank: 2
        ),
        XpLeaderboardEntry(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            xp: 3800,
            currentLevel: 8,
            avatarName: "FENRIR",
            heroPath: .brute,
            faction: .echoreach,
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
