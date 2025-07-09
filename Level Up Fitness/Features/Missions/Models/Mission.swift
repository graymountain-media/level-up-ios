import Foundation
import SwiftUI

enum MissionStatus: String, Codable {
    case available, inProgress, completed, claimed
}

class Mission: Identifiable, Codable {
    var id: String = UUID().uuidString
    let title: String
    let description: String
    let xpReward: Int
    let completionTime: Int // in hours for now
    let successRate: Int
    var status: MissionStatus
    let levelRequirement: Int
    var deadline: Date? = nil
    
    init(title: String, description: String, xpReward: Int, completionTime: Int, successRate: Int, status: MissionStatus, levelRequirement: Int) {
        self.title = title
        self.description = description
        self.xpReward = xpReward
        self.completionTime = completionTime
        self.successRate = successRate
        self.status = status
        self.levelRequirement = levelRequirement
    }
}
