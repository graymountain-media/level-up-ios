//
//  FactionHomeService.swift
//  Level Up
//
//  Created by Sam Smith on 9/3/25.
//
import SwiftUI
import Foundation

// MARK: Data Models
struct FactionDetails: Codable, Identifiable {
    let factionId: UUID
    let name: String
    let slogan: String
    let iconName: String
    let description: String
    let weeklyXP: Int
    let memberCount: Int
    let levelLine: Int
    let topLeaders: [Leader]

    var id: UUID { factionId }

    enum CodingKeys: String, CodingKey {
        case factionId = "faction_id"
        case name
        case slogan
        case iconName = "icon_name"
        case description
        case weeklyXP = "weekly_xp"
        case memberCount = "member_count"
        case levelLine = "level_line"
        case topLeaders = "top_leaders"
    }
}

struct Leader: Identifiable, Codable {
    let id = UUID() // Unique ID for SwiftUI
    let rank: String
    let name: String
    let avatarName: String // Name of the image asset for the avatar
    let level: Int
    let points: Int // Could be XP, contributions, etc.

    // For Codable if your backend uses snake_case
    enum CodingKeys: String, CodingKey {
        case rank
        case name
        case avatarName = "avatar_name"
        case level
        case points
    }
}

// MARK: - Error Types

enum FactionHomeError: LocalizedError {
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

protocol FactionHomeServiceProtocol {
    func fetchFactionDetails() async -> Result<FactionDetails, FactionHomeError>
}

class FactionHomeService: FactionHomeServiceProtocol {
    
    init() {}
    
    func fetchFactionDetails() async -> Result<FactionDetails, FactionHomeError> {
        let echoFaction = FactionDetails(
            factionId: UUID(uuidString: "7a1b9c4d-2e6f-4a8b-9e1c-3d5f7a9c2b8d")!,
            name: "The Iron Guardians",
            slogan: "Unbreakable. Unyielding. United.",
            iconName: "faction_iron_guard",
            description: "A faction forged in the fires of conflict, dedicated to protecting the innocent and upholding justice. Their members are known for their resilience and steadfast resolve in the face of adversity.",
            weeklyXP: 58742,
            memberCount: 345,
            levelLine: 165,
            topLeaders: [
                Leader(rank: "Faction Leader", name: "WALLYG", avatarName: "avatar_wallyg", level: 9, points: 2080),
                Leader(rank: "1st Officer", name: "EMBER", avatarName: "avatar_ember", level: 6, points: 900),
                Leader(rank: "2nd Officer", name: "NYX", avatarName: "avatar_nyx", level: 5, points: 540)
            ]
        )
        return .success(echoFaction)
    }
}
