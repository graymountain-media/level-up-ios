//
//  MissionManager.swift
//  Level Up
//
//  Created by Jake Gray on 8/2/25.
//

import Foundation
import FactoryKit

@MainActor
@Observable
class MissionManager {
    @ObservationIgnored @Injected(\.missionService) var missionService

    var availableMissions: [Mission] = []
    var activeMissions: [Mission] = []
    var completedMissions: [Mission] = []
    
    var isLoading: Bool = false
    
    var errorMessage: String? = nil
    
    private var allMissions: [Mission] = []
    private var missionTimers: [UUID: Timer] = [:]
    private var userMissions: [UserMission] = []
    private var lastReadyCheck: [UUID: Bool] = [:]
    
    var newlyCompletedMissions: [Mission] = []
    var showMissionReadyNotification: Bool = false
    var missionResult: MissionResult? = nil

    var currentUserLevel: Int = 1
    
    init() {}
    
    // Loads all missions and user_mission from backend, then updates state
    func loadAllMissions(_ currentUserLevel: Int) async {
        self.currentUserLevel = currentUserLevel
        isLoading = true
        errorMessage = nil
        let allMissionsResult = await missionService.fetchAllMissions()
        let userMissionsResult = await missionService.fetchUserMissions()
        
        guard case .success(let missions) = allMissionsResult,
              case .success(let userMissions) = userMissionsResult else {
            // Handle error
            isLoading = false
            errorMessage = "Failed to load missions. Please try again."
            return
        }
        self.allMissions = missions
        self.userMissions = userMissions
        
        print("🔍 DEBUG: Loaded \(missions.count) missions:")
        for mission in missions {
            print("🔍 DEBUG: - \(mission.title) (Level: \(mission.levelRequirement), Duration: \(mission.duration)h)")
        }
        print("🔍 DEBUG: Loaded \(userMissions.count) user missions")
        
        // Clear existing timers
        clearAllTimers()
        
        // Partition userMissions into completed, active, etc.
        let completedIds = Set(userMissions.filter { $0.completed }.map { $0.missionId })
        let activeIds = Set(userMissions.filter { $0.completed == false }.map { $0.missionId })
        self.completedMissions = missions.filter { completedIds.contains($0.id) }
        self.activeMissions = missions.filter { activeIds.contains($0.id) }
        allMissions.removeAll { mission in
            activeMissions.contains(mission) || completedMissions.contains(mission)
        }
        
        // Create timers for active missions
        createTimersForActiveMissions()
        
        updateAvailableMissions()
        isLoading = false
    }
    
    // Only show first mission per level until completed, then unlock second
    func updateAvailableMissions() {
        let userLevel = currentUserLevel
        // Identify the first two missions by title
        let firstMissionTitle = "Welcome to the Nexus"
        let secondMissionTitle = "Behind the Walls"
        let firstMission = allMissions.first(where: { $0.title == firstMissionTitle })
        let secondMission = allMissions.first(where: { $0.title == secondMissionTitle })
        
        // Check if first mission exists in remaining available missions
        if let first = firstMission {
            availableMissions = [first]
            return
        }
        
        // If first is not available, check if second exists and first is not in progress
        if let second = secondMission {
            guard activeMissions.contains(where: { $0.title == firstMissionTitle }) == false else {
                // if active missions is not empty, then the first mission is in progress and we need to wait for that to be completed
                availableMissions = []
                return
            }
            availableMissions = [second]
            return
        }
        // All other missions (not first two), unlocked by level and not completed
        let remaining = allMissions.filter {
            $0.title != firstMissionTitle &&
            $0.title != secondMissionTitle &&
            $0.levelRequirement <= userLevel
        }
        availableMissions = remaining
    }
    
    // Start a mission
    @MainActor
    func startMission(_ mission: Mission) async {
        let result = await missionService.startUserMission(mission: mission)
        switch result {
        case .success(let userMission):
            await loadAllMissions(currentUserLevel)
            setNotificationForNewMission(userMission)
        case .failure(let error):
            errorMessage = "Failed to start mission: \(error.localizedDescription)"
        }
    }
        
    private func setNotificationForNewMission(_ userMission: UserMission) {
        MissionNotificationManager.shared.requestAuthorizationIfNeeded()
        MissionNotificationManager.shared.scheduleMissionCompletionNotification(for: userMission)
    }
    
    // Complete mission and trigger global popup
    func completeMission(_ mission: Mission) {
        completedMissions.append(mission)
//        appState?.triggerMissionCompletePopup(for: mission, message: mission.successMessage)
        updateAvailableMissions()
    }
    
    // Dismiss popup and move to completed tab
    func dismissCompletionPopup() {
//        appState.showMissionCompletePopup = false
//        appState.missionCompletionMessage = nil
    }
    
    // MARK: - Timer Management
    
    private func clearAllTimers() {
        for timer in missionTimers.values {
            timer.invalidate()
        }
        missionTimers.removeAll()
    }
    
    private func createTimersForActiveMissions() {
        for mission in activeMissions {
            if let userMission = userMissions.first(where: { $0.missionId == mission.id }) {
                createTimer(for: mission, userMission: userMission)
            }
        }
    }
    
    private func createTimer(for mission: Mission, userMission: UserMission) {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMissionTimer(missionId: mission.id)
        }
        missionTimers[mission.id] = timer
    }
    
    private func updateMissionTimer(missionId: UUID) {
        guard let mission = activeMissions.first(where: { $0.id == missionId }) else { return }
        
        let isCurrentlyReady = isReadyToComplete(mission)
        let wasReady = lastReadyCheck[missionId] ?? false
        
        // Check if mission just became ready (transition from not ready to ready)
        if isCurrentlyReady && !wasReady {
            showMissionReadyNotification = true
            print("🔔 Mission \(mission.title) is now ready to complete!")
        }
        
        // Update the tracking
        lastReadyCheck[missionId] = isCurrentlyReady
    }
    
    func getRemainingTime(for mission: Mission) -> TimeInterval? {
        guard let userMission = userMissions.first(where: { $0.missionId == mission.id }) else {
            return nil
        }
        
        let now = Date()
        let timeRemaining = userMission.finishAt.timeIntervalSince(now)
        return max(0, timeRemaining)
    }
    
    func getFormattedRemainingTime(for mission: Mission) -> String? {
        guard let timeRemaining = getRemainingTime(for: mission) else {
            return nil
        }
        
        if timeRemaining <= 0 {
            return "Ready to Complete"
        }
        
        let hours = Int(timeRemaining) / 3600
        let minutes = Int(timeRemaining) % 3600 / 60
        let seconds = Int(timeRemaining) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    func isReadyToComplete(_ mission: Mission) -> Bool {
        guard let userMission = userMissions.first(where: { $0.missionId == mission.id }) else {
            return false
        }
        return Date() >= userMission.finishAt
    }
    
    private func handleMissionCompletion(_ mission: Mission) {
        // Stop and remove timer for this mission
        if let timer = missionTimers[mission.id] {
            timer.invalidate()
            missionTimers.removeValue(forKey: mission.id)
        }
        
        // Move mission from active to completed
        if let index = activeMissions.firstIndex(where: { $0.id == mission.id }) {
            activeMissions.remove(at: index)
            completedMissions.append(mission)
        }
        
        // Add to newly completed missions for AppState to observe
        newlyCompletedMissions.append(mission)
        
        // Update available missions
        updateAvailableMissions()
        
        // TODO: Call backend to mark mission as completed
        // This would be: await missionService.completeMission(mission.id)
    }
    
    func clearNewlyCompletedMissions() {
        newlyCompletedMissions.removeAll()
    }
    
    func dismissMissionReadyNotification() {
        showMissionReadyNotification = false
    }
    
    func dismissMissionResult() {
        missionResult = nil
    }
    
    // Complete a mission with success/fail roll
    func completeMission(_ mission: Mission, isDebug: Bool = false) async {
        guard isReadyToComplete(mission) || isDebug else {
            print("⚠️ Mission \(mission.title) is not ready to complete")
            return
        }
        
        // Roll for success based on mission success chances
        let successChance = mission.successChances.base ?? 50
        let roll = Int.random(in: 1...100)
        let isSuccess = roll <= successChance
        
        print("🎲 Rolling for mission \(mission.title): \(roll)/100 (need ≤\(successChance)) = \(isSuccess ? "SUCCESS" : "FAIL")")
        
        if isSuccess {
            // Success: Show success message and add to completed
            let successMessage = mission.successMessage
            await showMissionResult(mission: mission, isSuccess: true, message: successMessage, isDebug: isDebug)
        } else {
            // Failure: Show fail message but don't add to completed (stays active for retry)
            let failMessage: String
            if let missionFailMessage = mission.failMessage, 
               !missionFailMessage.isEmpty && 
               missionFailMessage.lowercased() != "none" {
                failMessage = missionFailMessage
            } else {
                failMessage = "Mission unsuccessful this time. Regroup and try again when you're ready!"
            }
            await showMissionResult(mission: mission, isSuccess: false, message: failMessage, isDebug: isDebug)
        }
    }
    
    private func showMissionResult(mission: Mission, isSuccess: Bool, message: String, isDebug: Bool) async {
        // Set mission result for popup
        missionResult = MissionResult(mission: mission, isSuccess: isSuccess, message: message)
        
        var result: Result<Void, MissionServiceError>
        if !isDebug {
            // Make API call to update backend
            result = await missionService.completeMission(mission: mission, success: isSuccess)
        } else {
            result = .success(())
        }
        
        switch result {
        case .success:
            print("✅ Mission completion API call successful")
            // Refresh all missions to get updated state from backend
            await loadAllMissions(currentUserLevel)
        case .failure(let error):
            print("❌ Mission completion API call failed: \(error.localizedDescription)")
            // Still refresh to ensure consistency with backend state
            await loadAllMissions(currentUserLevel)
        }
    }
    
    #if DEBUG
    // Debug method to instantly complete a mission
    func debugCompleteMission(_ mission: Mission) {
        print("🐛 DEBUG: debugCompleteMission called for: \(mission.title)")
        Task {
            await completeMission(mission, isDebug: true)
        }
    }
    #endif

}


enum MissionBoardTab: String, CaseIterable, Identifiable {
    case available
    case active
    case completed
    
    var id: String { self.rawValue }
    var displayName: String { self.rawValue.capitalized }
}
