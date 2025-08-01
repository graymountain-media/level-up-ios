import Foundation
import Combine
import Supabase
import FactoryKit

@Observable
class MissionBoardViewModel {
    var availableMissions: [Mission] = []
    var activeMissions: [Mission] = []
    var completedMissions: [Mission] = []
    var selectedTab: MissionBoardTab = .missionBoard
    var activeMission: Mission? = nil
    var missionTimer: Timer? = nil
    var missionTimeRemaining: Int = 0 // seconds
    var showMissionCompletePopup: Bool = false
    var missionCompletionMessage: String? = nil
    
    private var allMissions: [Mission] = [] // All missions, for unlocking logic
    private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored @Injected(\.missionService) var missionService: MissionServiceProtocol
    
    // Loads all missions and user_mission from backend, then updates state
    func loadAllMissions() async {
        let allMissionsResult = await missionService.fetchAllMissions()
        let userMissionsResult = await missionService.fetchUserMissions()
        
        guard case .success(let missions) = allMissionsResult,
              case .success(let userMissions) = userMissionsResult else {
            // Handle error (could add @Published error property)
            return
        }
        self.allMissions = missions
        // Partition userMissions into completed, active, etc.
        let completedIds = Set(userMissions.filter { $0.completed }.map { $0.missionId })
        let activeIds = Set(userMissions.filter { $0.completed == false }.map { $0.missionId })
        self.completedMissions = missions.filter { completedIds.contains($0.id) }
        self.activeMissions = missions.filter { activeIds.contains($0.id) }
        updateAvailableMissions()
    }
    
    // Only show first mission per level until completed, then unlock second
    func updateAvailableMissions() {
        var unlocked: [Mission] = []
        let grouped = Dictionary(grouping: allMissions, by: { $0.levelRequirement })
        for (_, missions) in grouped.sorted(by: { $0.key < $1.key }) {
            if let first = missions.first, !completedMissions.contains(where: { $0.id == first.id }) {
                unlocked.append(first)
                break
            } else if let first = missions.first, completedMissions.contains(where: { $0.id == first.id }), missions.count > 1 {
                let second = missions[1]
                if !completedMissions.contains(where: { $0.id == second.id }) {
                    unlocked.append(second)
                    break
                }
            }
        }
        availableMissions = unlocked
    }
    
    // Start a mission
    func startMission(_ mission: Mission) {
        activeMission = mission
        missionTimeRemaining = mission.duration * 60 * 60 // hours to seconds
        missionTimer?.invalidate()
        missionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.missionTimeRemaining -= 1
            if self.missionTimeRemaining <= 0 {
                timer.invalidate()
                self.completeMission(mission)
            }
        }
    }
    
    // Complete mission and show popup next app open
    func completeMission(_ mission: Mission) {
        completedMissions.append(mission)
        activeMission = nil
        showMissionCompletePopup = true
        missionCompletionMessage = mission.successMessage
        updateAvailableMissions()
    }
    
    // Retry mission after fail
    func retryMission(_ mission: Mission) {
        startMission(mission)
    }
    
    // Dismiss popup and move to completed tab
    func dismissCompletionPopup() {
        showMissionCompletePopup = false
        missionCompletionMessage = nil
        selectedTab = .activeMissions // or .completedMissions if you add that tab
    }
}

enum MissionBoardTab: String, CaseIterable {
    case missionBoard = "Mission Board"
    case activeMissions = "Active Missions"
    // Add .completedMissions if you want a separate completed tab
}
