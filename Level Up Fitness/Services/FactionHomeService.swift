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
    let avatarName: String
    let avatarImageUrl: String
    let level: Int
    let xpPoints: Int
    var rank: String? = nil

    enum CodingKeys: String, CodingKey {
        case rank
        case avatarName = "avatar_name"
        case avatarImageUrl = "avatar_image_url"
        case level
        case xpPoints = "xp_points"
    }
}

struct FactionMember: Codable, Identifiable {
    let id: UUID
    let avatarName: String
    let avatarImageUrl: String?
    let level: Int
    let xpPoints: Int
    let heroPath: HeroPath?
    var rank: String? = nil

    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case avatarName = "avatar_name"
        case avatarImageUrl = "avatar_image_url"
        case level = "current_level"
        case xpPoints = "xp_points"
        case heroPath = "hero_path"
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
    func getFactionMembers() async -> Result<[FactionMember], FactionHomeError>
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
            let updatedResponse: FactionDetails = configureTopLeaders(response)
            
            return .success(updatedResponse)
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
    
    private func configureTopLeaders(_ details: FactionDetails) -> FactionDetails {
        let sortedLeaders = details.topLeaders.sorted { $0.xpPoints > $1.xpPoints }
        let rankedLeaders = sortedLeaders.enumerated().map { (index, leader) -> Leader in
            var newLeader = leader
            switch index {
            case 0:
                newLeader.rank = "Faction Leader"
            case 1:
                newLeader.rank = "1st Officer"
            case 2:
                newLeader.rank = "2nd Officer"
            default:
                newLeader.rank = nil
            }
            return newLeader
        }
        let updatedResponse = FactionDetails(
            faction: details.faction,
            weeklyXP: details.weeklyXP,
            memberCount: details.memberCount,
            topLeaders: rankedLeaders
        )
        return updatedResponse
    }
    
    func getFactionMembers() async -> Result<[FactionMember], FactionHomeError> {
        guard (currentUserFaction != nil) else {
            return .failure(.unknownError("Has no faction"))
        }
        
        do {
            let response: [FactionMember] = try await client
                .rpc("get_faction_members", params: ["target_faction": currentUserFaction])
                .execute()
                .value
            
            let rankedResponse = response.enumerated().map { index, member in
                var updated = member
                switch index {
                case 0: updated.rank = "Faction Leader"
                case 1: updated.rank = "1st Officer"
                case 2: updated.rank = "2nd Officer"
                default: break
                }
                return updated
            }
            
            return .success(rankedResponse)
        } catch {
            return .failure(.unknownError(error.localizedDescription))
        }
    }

}
