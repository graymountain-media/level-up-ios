import Foundation
import Supabase
import FactoryKit

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
    func startUserMission(mission: Mission) async -> Result<UserMission, MissionServiceError>
    func completeMission(mission: Mission, success: Bool) async -> Result<Void, MissionServiceError>
}

// MARK: - Models

struct UserMission: Codable, Identifiable, Equatable {
    let userId: UUID
    let missionId: UUID
    let completed: Bool
    let startedAt: Date
    let finishAt: Date
    
    var id: UUID {
        return userId
    }
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case missionId = "mission_id"
        case completed
        case startedAt = "started_at"
        case finishAt = "finish_at"
    }
}

// MARK: - Implementation

@MainActor
class MissionService: MissionServiceProtocol {
    @ObservationIgnored @Injected(\.trackingService) private var tracking: TrackingProtocol
    func startUserMission(mission: Mission) async -> Result<UserMission, MissionServiceError> {
        guard let userId = client.auth.currentUser?.id else {
            return .failure(.notAuthenticated)
        }
        let now = Date()
        let finishAt = Calendar.current.date(byAdding: .hour, value: mission.duration, to: now) ?? now
        let userMission = UserMission(
            userId: userId,
            missionId: mission.id,
            completed: false,
            startedAt: now,
            finishAt: finishAt
        )
        do {
            let _: [UserMission] = try await client.from("user_missions")
                .insert([userMission])
                .select()
                .execute()
                .value
            // Track mission claimed
            tracking.track(.missionStarted(missionId: mission.id.uuidString))

            return .success(userMission)
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    init() {}
    
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
    
    func completeMission(mission: Mission, success: Bool) async -> Result<Void, MissionServiceError> {
        guard let userId = client.auth.currentUser?.id else {
            return .failure(.notAuthenticated)
        }
        
        do {
            if success {
                // Mark mission as completed in user_missions
                let _: [UserMission] = try await client.from("user_missions")
                    .update(["completed": true])
                    .eq("user_id", value: userId)
                    .eq("mission_id", value: mission.id)
                    .select()
                    .execute()
                    .value
                
                // Award gold to user profile using RPC
                let _: [[String: AnyJSON]] = try await client.rpc(
                    "add_gold_to_profile",
                    params: [
                        "user_id": AnyJSON.string(userId.uuidString),
                        "gold_amount": AnyJSON.integer(mission.reward)
                    ]
                )
                    .execute()
                    .value
            } else {
                // Delete the user_mission row on failure
                try await client.from("user_missions")
                    .delete()
                    .eq("user_id", value: userId)
                    .eq("mission_id", value: mission.id)
                    .execute()
            }

            // Track mission completion
            tracking.track(.missionCompleted(missionId: mission.id.uuidString, success: success))

            return .success(())
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }
}
