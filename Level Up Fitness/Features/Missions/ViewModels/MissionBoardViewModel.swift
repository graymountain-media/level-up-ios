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
                title: "Retrieve the Lost Core",
                description: "A core from the Rift was dropped deep in the barrens. Recover it.",
                fluxReward: 150,
                successRate: 100,
                status: .available,
                levelRequirement: 1,
            )
        ]
    }
    
    func startMission(_ mission: Mission) {
        if let index = availableMissions.firstIndex(where: { $0.id == mission.id }) {
            var updatedMission = availableMissions[index]
            updatedMission.status = .inProgress
            availableMissions.remove(at: index)
            activeMissions.append(updatedMission)
        }
    }
    
    func completeMission(_ mission: Mission) {
        if let index = activeMissions.firstIndex(where: { $0.id == mission.id }) {
            var updatedMission = activeMissions[index]
            updatedMission.status = .completed
            activeMissions[index] = updatedMission
        }
    }
    
    func claimReward(for mission: Mission) {
        if let index = activeMissions.firstIndex(where: { $0.id == mission.id }) {
            var updatedMission = activeMissions[index]
            updatedMission.status = .claimed
            activeMissions[index] = updatedMission
        }
    }
}

enum MissionBoardTab: String, CaseIterable {
    case missionBoard = "Mission Board"
    case activeMissions = "Active Missions"
}
