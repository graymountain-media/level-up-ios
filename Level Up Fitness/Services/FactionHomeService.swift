//
//  FactionHomeService.swift
//  Level Up
//
//  Created by Sam Smith on 9/3/25.
//
import SwiftUI
import Foundation
import FactoryKit

// MARK: Data Models
struct FactionDetails: Codable, Identifiable {
    let id: UUID = UUID()
    let factionName: String
    let weeklyXP: Int
    let memberCount: Int
    let topLeaders: [Leader]
    
    var faction: Faction? {
        Faction(rawValue: factionName.rawValue)
    }
    
    var levelLine: Int {
        return Int(weeklyXP/memberCount)
    }

    enum CodingKeys: String, CodingKey {
        case factionName = "faction_name"
        case weeklyXP = "weekly_xp"
        case memberCount = "member_count"
        case topLeaders = "top_leaders"
    }
}

struct Leader: Identifiable, Codable {
    let id = UUID()
    let rank: String? = nil
    let avatarName: String
    let avatarImageUrl: String
    let level: Int
    let xpPoints: Int // Could be XP, contributions, etc.

    // For Codable if your backend uses snake_case
    enum CodingKeys: String, CodingKey {
        case rank
        case avatarName = "avatar_name"
        case avatarImageUrl = "avatar_image_url"
        case level
        case xpPoints = "xp_points"
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

@MainActor
class FactionHomeService: FactionHomeServiceProtocol {
    @ObservationIgnored @Injected(\.appState) var appState

    init() {}
    
    private var isAuthenticated: Bool {
        return appState.isAuthenticated
    }
    
    private var currentUserId: UUID? {
        return client.auth.currentUser?.id
    }
    
    func fetchFactionDetails() async -> Result<FactionDetails, FactionHomeError> {
        guard isAuthenticated else {
            return .failure(.notAuthenticated)
        }
        
        do {
            let response = try await client
                .rpc("get_faction_overview", params: ["user_id": currentUserId])
                .execute()
            
            // Decode the data into your FactionDetails model
            let factionDetails = try JSONDecoder().decode(FactionDetails.self, from: response.data)
            
            return .success(factionDetails)
        } catch {
            if let decodingError = error as? DecodingError {
                return .failure(.unknownError(decodingError.localizedDescription))
            } else {
                return .failure(.databaseError(error.localizedDescription))
            }
        }
    }
}
