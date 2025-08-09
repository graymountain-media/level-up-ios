import Foundation
import SwiftUI

enum MissionStatus: String, Codable {
    case available, inProgress, completed, claimed
}


struct SuccessChances: Codable, Equatable {
    var base: Int?
    var brute: Int?
    var ranger: Int?
    var sentinel: Int?
    var hunter: Int?
    var juggernaut: Int?
    var strider: Int?
    var champion: Int?
    var display: Int?
    
    enum CodingKeys: String, CodingKey {
        case base = "Base"
        case brute = "Brute"
        case ranger = "Ranger"
        case sentinel = "Sentinel"
        case hunter = "Hunter"
        case juggernaut = "Juggernaut"
        case strider = "Strider"
        case champion = "Champion"
        case display = "Display"
    }
}

struct Mission: Identifiable, Codable, Equatable {
    static let testData: [Mission] = [
        Mission(
            title: "Explore New Area",
            description: "A distortion in the Signal Grid has revealed an uncharted sector of the Echoverse. Your directive: Traverse unknown terrain, avoid detection, and deploy a Signal Node beacon.",
            levelRequirement: 1,
            successChances: SuccessChances(base: 100, brute: 100, ranger: 100, sentinel: 100, hunter: 100, juggernaut: 100, strider: 100, champion: 100, display: 100),
            duration: 72,
            successMessage: "You successfully explored the new area and deployed the beacon!",
            failMessage: "You were detected and had to retreat. Try again tomorrow.",
            reward: 100
        ),
        Mission(
            title: "Signal Grid Recovery",
            description: "Deploy the advanced cyberwarfare suite, establish a covert connection to their mainframe, and extract strategic data without triggering alarm systems.",
            levelRequirement: 1,
            successChances: SuccessChances(base: 90, brute: 95, ranger: 85, display: 90),
            duration: 48,
            successMessage: "Signal Grid restored!",
            failMessage: "Grid recovery failed. Try again.",
            reward: 45
        ),
        Mission(
            title: "Relic Extraction Protocol",
            description: "Infiltrate the containment zone, neutralize security measures, and extract the relic before the next solar flare.",
            levelRequirement: 1,
            successChances: SuccessChances(base: 65, brute: 70, ranger: 60, sentinel: 65, hunter: 60, juggernaut: 75, strider: 60, champion: 80, display: 65),
            duration: 96,
            successMessage: "Artifact extracted! Your team gains valuable data.",
            failMessage: "Extraction failed. The artifact destabilized and was lost.",
            reward: 40
        ),
//        // DEBUG: Short missions for testing completion
//        Mission(
//            title: "DEBUG: Quick Test Mission",
//            description: "A quick 10-second mission for testing completion popup functionality.",
//            levelRequirement: 1,
//            successChances: SuccessChances(base: 100, display: 100),
//            duration: 1, // 1 hour for normal testing, but will complete immediately with debug button
//            successMessage: "Debug mission completed successfully! 🎉",
//            failMessage: "Debug mission failed.",
//            reward: 5
//        ),
//        Mission(
//            title: "DEBUG: Fast Completion Test",
//            description: "A 30-second test mission to verify timer and popup systems.",
//            levelRequirement: 1,
//            successChances: SuccessChances(base: 100, display: 100),
//            duration: 2, // 2 hours for normal testing, but will complete immediately with debug button
//            successMessage: "Fast test mission complete! Timer system working! ⚡",
//            failMessage: "Fast test failed.",
//            reward: 10
//        )
    ]

    var id: UUID
    let title: String
    let description: String
    let levelRequirement: Int
    let successChances: SuccessChances // Path name to chance, null means not available
    let duration: Int // hours
    let successMessage: String
    let failMessage: String?
    let reward: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case levelRequirement = "level_requirement"
        case successChances = "success_chances"
        case duration
        case successMessage = "success_message"
        case failMessage = "fail_message"
        case reward
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        levelRequirement: Int,
        successChances: SuccessChances,
        duration: Int,
        successMessage: String,
        failMessage: String? = nil,
        reward: Int
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.levelRequirement = levelRequirement
        self.successChances = successChances
        self.duration = duration
        self.successMessage = successMessage
        self.failMessage = failMessage
        self.reward = reward
    }
    
    /// Get the success rate for a specific hero path, falling back to base rate
    func successRate(for path: HeroPath?) -> Int {
        guard let path = path else {
            return successChances.base ?? 50
        }
        
        switch path {
        case .brute:
            return successChances.brute ?? successChances.base ?? 50
        case .ranger:
            return successChances.ranger ?? successChances.base ?? 50
        case .sentinel:
            return successChances.sentinel ?? successChances.base ?? 50
        case .hunter:
            return successChances.hunter ?? successChances.base ?? 50
        case .juggernaut:
            return successChances.juggernaut ?? successChances.base ?? 50
        case .strider:
            return successChances.strider ?? successChances.base ?? 50
        case .champion:
            return successChances.champion ?? successChances.base ?? 50
        }
    }
}
