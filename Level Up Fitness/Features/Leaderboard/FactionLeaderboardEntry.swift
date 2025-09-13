//
//  FactionLeaderboardEntry.swift
//  Level Up
//
//  Created by Jake Gray on 8/25/25.
//

import Foundation

struct FactionLeaderboardEntry: LeaderboardEntry {
    var heroPath: HeroPath? = nil
    
    var profilePictureURL: String? {
        return topPlayerImage
    }
    
    let faction: Faction?
    let totalXp: Int
    let memberCount: Int
    let topPlayerName: String
    let topPlayerXp: Int
    var topPlayerImage: String? = nil
    let topPlayerLevel: Int
    let rank: Int
    
    // Conform to LeaderboardEntry protocol
    var userId: UUID { UUID() } // Not applicable for factions, but required
    var value: Int { totalXp }
    var avatarName: String? { topPlayerName }
    var id: UUID { UUID() }
    var level: Int { topPlayerLevel }
    
    enum CodingKeys: String, CodingKey {
        case faction
        case totalXp = "total_xp"
        case memberCount = "member_count"
        case topPlayerName = "top_player_name"
        case topPlayerXp = "top_player_xp"
        case topPlayerImage = "top_player_image"
        case topPlayerLevel = "top_player_level"
        case rank
    }
    
    init(faction: Faction, totalXp: Int, memberCount: Int, topPlayerName: String, topPlayerXp: Int, topPlayerLevel: Int, rank: Int) {
        self.faction = faction
        self.totalXp = totalXp
        self.memberCount = memberCount
        self.topPlayerName = topPlayerName
        self.topPlayerXp = topPlayerXp
        self.topPlayerLevel = topPlayerLevel
        self.rank = rank
    }
    
    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<FactionLeaderboardEntry.CodingKeys> = try decoder.container(keyedBy: FactionLeaderboardEntry.CodingKeys.self)
        
        self.faction = try container.decodeIfPresent(Faction.self, forKey: FactionLeaderboardEntry.CodingKeys.faction)
        self.totalXp = try container.decode(Int.self, forKey: FactionLeaderboardEntry.CodingKeys.totalXp)
        self.memberCount = try container.decode(Int.self, forKey: FactionLeaderboardEntry.CodingKeys.memberCount)
        self.topPlayerName = try container.decode(String.self, forKey: FactionLeaderboardEntry.CodingKeys.topPlayerName)
        self.topPlayerXp = try container.decode(Int.self, forKey: FactionLeaderboardEntry.CodingKeys.topPlayerXp)
        self.topPlayerImage = try container.decodeIfPresent(String.self, forKey: FactionLeaderboardEntry.CodingKeys.topPlayerImage)
        self.topPlayerLevel = try container.decode(Int.self, forKey: FactionLeaderboardEntry.CodingKeys.topPlayerLevel)
        self.rank = try container.decode(Int.self, forKey: FactionLeaderboardEntry.CodingKeys.rank)
        
    }
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        totalXp = try container.decode(Int.self, forKey: .totalXp)
//        memberCount = try container.decode(Int.self, forKey: .memberCount)
//        topPlayerName = try container.decode(String.self, forKey: .topPlayerName)
//        topPlayerXp = try container.decode(Int.self, forKey: .topPlayerXp)
//        rank = try container.decode(Int.self, forKey: .rank)
//        
//        // Convert string to Faction enum
//        let factionString = try container.decode(String.self, forKey: .faction)
//        faction = Faction.fromString(factionString) ?? .echoreach
//    }

}
