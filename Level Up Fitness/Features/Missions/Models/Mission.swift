import Foundation
import SwiftUI

enum MissionStatus: String, Codable {
    case available, inProgress, completed, claimed
}

struct Mission: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let fluxReward: Int
    let successRate: Int
    var status: MissionStatus
    let levelRequirement: Int
}
