import Foundation
import Supabase

// MARK: - Error Types

enum MissionServiceError: LocalizedError {
    case notAuthenticated
    case networkError(String)
    case databaseError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to access missions"
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

protocol MissionServiceProtocol {
    func fetchAllMissions() async -> Result<[Mission], MissionServiceError>
    func fetchUserMissions() async -> Result<[UserMission], MissionServiceError>
}

// MARK: - Models

struct UserMission: Codable, Identifiable, Equatable {
    let userId: UUID
    let missionId: UUID
    let completed: Bool
    let startedAt: Date
    let completedAt: Date
    
    var id: UUID {
        return userId
    }
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case missionId = "mission_id"
        case completed
        case startedAt = "started_at"
        case completedAt = "completed_at"
    }
}

// MARK: - Implementation

@MainActor
class MissionService: MissionServiceProtocol {
    private let client: SupabaseClient
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    func fetchAllMissions() async -> Result<[Mission], MissionServiceError> {
        do {
            let missions: [Mission] = try await client.from("missions")
                .select()
                .order("level_requirement", ascending: true)
                .execute()
                .value
            return .success(missions)
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func fetchUserMissions() async -> Result<[UserMission], MissionServiceError> {
        guard let userId = client.auth.currentUser?.id else { return .failure(.databaseError("No user ID found"))}
        do {
            let userMissions: [UserMission] = try await client.from("user_missions")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            return .success(userMissions)
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }
}
