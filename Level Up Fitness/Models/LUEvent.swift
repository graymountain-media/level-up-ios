import Foundation

enum LUEvent {
    case onboardingCompleted
    case factionJoined(faction: String)
    case workoutStart(type: String)
    case workoutComplete(type: String, duration: Int, xpEarned: Int)
    case missionClaimed(missionId: String)
    case missionCompleted(missionId: String, success: Bool)
    case drillCompleted(category: String, xpEarned: Int)
    case levelUp(newLevel: Int)
    case itemPurchased(itemId: String, cost: Int)
    case itemEquipped(itemId: String, slot: String)
    case friendAdded(friendId: String)
    case xpAwarded(amount: Int, source: String)

    var apiValue: String {
        switch self {
        case .onboardingCompleted:
            return "onboarding_completed"
        case .factionJoined:
            return "faction_joined"
        case .workoutStart:
            return "workout_start"
        case .workoutComplete:
            return "workout_complete"
        case .missionClaimed:
            return "mission_claimed"
        case .missionCompleted:
            return "mission_completed"
        case .drillCompleted:
            return "drill_completed"
        case .levelUp:
            return "level_up"
        case .itemPurchased:
            return "item_purchased"
        case .itemEquipped:
            return "item_equipped"
        case .friendAdded:
            return "friend_added"
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
        case .workoutStart(let type):
            return ["workout_type": type]
        case .workoutComplete(let type, let duration, let xpEarned):
            return ["workout_type": type, "duration": duration, "xp_earned": xpEarned]
        case .missionClaimed(let missionId):
            return ["mission_id": missionId]
        case .missionCompleted(let missionId, let success):
            return ["mission_id": missionId, "success": success]
        case .drillCompleted(let category, let xpEarned):
            return ["category": category, "xp_earned": xpEarned]
        case .levelUp(let newLevel):
            return ["new_level": newLevel]
        case .itemPurchased(let itemId, let cost):
            return ["item_id": itemId, "cost": cost]
        case .itemEquipped(let itemId, let slot):
            return ["item_id": itemId, "slot": slot]
        case .friendAdded(let friendId):
            return ["friend_id": friendId]
        case .xpAwarded(let amount, let source):
            return ["amount": amount, "source": source]
        }
    }
}