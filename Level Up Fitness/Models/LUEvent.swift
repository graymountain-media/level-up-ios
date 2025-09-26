import Foundation

enum LUEvent {
    case onboardingCompleted
    case factionJoined(faction: String)
    case workoutComplete(type: String, duration: Int, xpEarned: Int)
    case missionStarted(missionId: String)
    case missionCompleted(missionId: String, success: Bool)
    case drillCompleted(category: String)
    case levelUp(newLevel: Int)
    case xpAwarded(amount: Int, source: String)

    var apiValue: String {
        switch self {
        case .onboardingCompleted:
            return "onboarding_completed"
        case .factionJoined:
            return "faction_joined"
        case .workoutComplete:
            return "workout_complete"
        case .missionCompleted:
            return "mission_completed"
        case .drillCompleted:
            return "drill_completed"
        case .levelUp:
            return "level_up"
        case .xpAwarded:
            return "xp_awarded"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .onboardingCompleted:
            return [:]
        case .factionJoined(let faction):
            return ["faction": faction]
        case .workoutComplete(let type, let duration, let xpEarned):
            return ["workout_type": type, "duration": duration, "xp_earned": xpEarned]
        case .missionCompleted(let missionId, let success):
            return ["mission_id": missionId, "success": success]
        case .levelUp(let newLevel):
            return ["new_level": newLevel]
        case .xpAwarded(let amount, let source):
            return ["amount": amount, "source": source]
        }
    }
}
