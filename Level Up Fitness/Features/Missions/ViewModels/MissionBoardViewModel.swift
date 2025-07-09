import Foundation
import Combine

class MissionBoardViewModel: ObservableObject {
    @Published var availableMissions: [Mission] = []
    @Published var activeMissions: [Mission] = []
    @Published var selectedTab: MissionBoardTab = .missionBoard
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample available missions
        availableMissions = [
            Mission(
                title: "Explore New Area",
                description: """
                A distortion in the Signal Grid has revealed an uncharted sector of the Echoverse. Pulse readings suggest traces of relic activity buried deep within. No established paths, no maps—just static and silence. The Council has authorized a single scout party to breach the boundary and collect data on environmental conditions, enemy presence, and potential resource caches.
                Your directive: Traverse unknown terrain, avoid detection, and deploy a Signal Node beacon. Survival odds are low. Glory, however, is guaranteed.
                """,
                xpReward: 1300,
                completionTime: 72,
                successRate: 100,
                status: .available,
                levelRequirement: 1,
            ),
            Mission(
                title: "Relic Extraction Protocol",
                description: """
                Deep scans have detected a powerful ancient artifact emitting unstable energy signatures in the Void Wastes. The artifact appears to be of Precursor origin, potentially containing invaluable technological data. However, the surrounding area is heavily contaminated with temporal radiation and patrolled by autonomous defense systems.
                Your directive: Infiltrate the containment zone, neutralize security measures, and extract the relic before the next solar flare disrupts the extraction window. The artifact is highly unstable—handle with extreme caution. Success will significantly advance our technological capabilities.
                """,
                xpReward: 1800,
                completionTime: 96,
                successRate: 65,
                status: .available,
                levelRequirement: 5
            ),
            Mission(
                title: "Neural Network Breach",
                description: """
                The Collective's central neural network has revealed a temporary vulnerability in its quantum encryption. This rare opportunity allows for the extraction of classified intelligence on their upcoming offensive operations. The window is narrow—their adaptive security protocols will detect and seal any intrusion within hours.
                Your directive: Deploy the advanced cyberwarfare suite, establish a covert connection to their mainframe, and extract strategic data without triggering alarm systems. If detected, immediate extraction is mandatory. The intelligence gathered could prevent the fall of our outer settlements and save countless lives.
                """,
                xpReward: 1500,
                completionTime: 48,
                successRate: 80,
                status: .available,
                levelRequirement: 3
            )
        ]
    }
    
    func startMission(_ mission: Mission) {
        mission.status = .inProgress
        mission.deadline = Calendar.current.date(byAdding: .hour, value: mission.completionTime, to: .now)
        self.objectWillChange.send()
    }
    
    func completeMission(_ mission: Mission) {
        mission.status = .completed
    }
    
    func claimReward(for mission: Mission) {
        mission.status = .claimed
    }
}

enum MissionBoardTab: String, CaseIterable {
    case missionBoard = "Mission Board"
    case activeMissions = "Active Missions"
}
