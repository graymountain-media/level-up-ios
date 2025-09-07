//
//  FactionHomeService.swift
//  Level Up
//
//  Created by Sam Smith on 9/3/25.
//
import SwiftUI
import Foundation
import FactoryKit
import Helpers

// MARK: Data Models
struct FactionDetails: Codable, Identifiable {
    let id: UUID = UUID()
    let faction: Faction
    let weeklyXP: Int
    let memberCount: Int
    let topLeaders: [Leader]
    
    var levelLine: Int {
        return Int(weeklyXP/memberCount)
    }

    enum CodingKeys: String, CodingKey {
        case faction
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
    
    private var currentUserFaction: Faction? {
        return appState.userAccountData?.profile.faction
    }
    
    func fetchFactionDetails() async -> Result<FactionDetails, FactionHomeError> {
        guard isAuthenticated else {
            return .failure(.notAuthenticated)
        }
        
        guard (currentUserFaction != nil) else {
            return .failure(.unknownError("Has no faction"))
        }
        
        do {
            let response: FactionDetails = try await client
                .rpc("get_faction_overview", params: ["target_faction": currentUserFaction])
                .single()
                .execute()
                .value
                
            return .success(response)
        } catch {
            // Handle database errors
            if let apiError = error as? PostgrestError {
                return .failure(.databaseError(apiError.message))
            }
            
            // Handle the specific decoding error for a null or empty response
            if let decodingError = error as? DecodingError, case .valueNotFound(_, _) = decodingError {
                return .failure(.unknownError("No Data Returned"))
            }
            
            // Fallback for any other unexpected errors
            return .failure(.unknownError(error.localizedDescription))
        }
    }
}
