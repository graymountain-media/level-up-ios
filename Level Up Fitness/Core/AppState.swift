//
//  AppState.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI
import Combine
import Supabase
import FactoryKit

// MARK: - Notification Names
extension Notification.Name {
    static let showMissionsUnlockedTip = Notification.Name("showMissionsUnlockedTip")
}

@Observable
@MainActor
class AppState {
    @ObservationIgnored @Injected(\.missionManager) var missionManager
    @ObservationIgnored @Injected(\.userDataService) var userDataService
    @ObservationIgnored @Injected(\.levelManager) var levelManager
    @ObservationIgnored @Injected(\.itemService) var itemService
    // Navigation state
    var isShowingMenu: Bool = false
    var selectedMenuItem: MenuItem?
    var currentTab: MainTab = .home
    var isShowingHelp: Bool = false
    
    // Mission Ready Notification State
    var showMissionReadyPopup: Bool {
        missionManager.showMissionReadyNotification
    }
    
    func dismissMissionReadyPopup() {
        missionManager.dismissMissionReadyNotification()
    }
    
    var showLevelUpPopup: Bool = false
    
    func showLevelPopupIfNeeded() {
        currentTab = .home
        showLevelUpPopup = levelManager.pendingLevelUpNotification != nil
    }
    
    var levelUpNotification: LevelUpNotification? {
        levelManager.pendingLevelUpNotification
    }
    
    // Faction Selection State
    private var shouldShowFactionSelection: Bool = false
    
    var showFactionSelection: Bool {
        // Only show faction selection if no other popups are showing
        shouldShowFactionSelection && !showLevelUpPopup && !showPathAssignment
    }
    
    // Path Assignment State
    private var shouldShowPathAssignment: Bool = false
    
    var showPathAssignment: Bool {
        // Only show path assignment if no other popups are showing
        shouldShowPathAssignment && !showLevelUpPopup && !showFactionSelection
    }
    
    var pendingPathAssignment: HeroPath? {
        levelManager.pendingPathAssignment
    }
    
    func dismissLevelUpPopup() {
        // Store unlocked content and path assignment before dismissing
        let unlockedContent = levelManager.pendingLevelUpNotification?.unlockedContent ?? []
        let hasFactionUnlock = unlockedContent.contains(.factions)
        let hasPathAssignment = levelManager.pendingPathAssignment != nil
        
        levelManager.dismissLevelUpNotification()
        showLevelUpPopup = false
        
        // If path was assigned, show path assignment first
        if hasPathAssignment {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shouldShowPathAssignment = true
            }
        } else if hasFactionUnlock {
            // If factions were unlocked, show faction selection after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shouldShowFactionSelection = true
            }
        } else {
            // Otherwise, trigger content unlock tips
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.triggerUnlockedContentTips(unlockedContent)
            }
        }
    }
    
    func selectFaction(_ faction: Faction) {
        Task {
            await levelManager.completeFactionSelection(faction)
            
            // Refresh user data to get updated faction
            await refreshUserData()
            
            // Dismiss faction selection
            await MainActor.run {
                self.shouldShowFactionSelection = false
                self.currentTab = .home
                // After faction selection, trigger any remaining content unlock tips
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Get the unlocked content that triggered faction selection
                    self.triggerUnlockedContentTips([.factions, .factionLeaderboards])
                }
            }
        }
    }
    
    func dismissFactionSelection() {
        shouldShowFactionSelection = false
        levelManager.dismissFactionSelection()
    }
    
    func dismissPathAssignment() {
        shouldShowPathAssignment = false
        levelManager.dismissPathAssignment()
        
        // After path assignment, check if we need to show faction selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Check if faction selection should be shown (this would be from a previous level up)
            if self.levelManager.pendingFactionSelection {
                self.shouldShowFactionSelection = true
            }
        }
    }
    
    // Content Unlock Tips
    private func triggerUnlockedContentTips(_ unlockedContent: [UnlockableContent]) {
        for content in unlockedContent {
            switch content {
            case .missions:
                // Trigger missions tab tip - this will show the messageOverlay
                NotificationCenter.default.post(
                    name: .showMissionsUnlockedTip,
                    object: nil
                )
            case .factions:
                // Factions unlock is handled by faction selection view
                // Could trigger a tip about faction features here if needed
                break
            case .factionLeaderboards:
                // Could trigger a tip about faction leaderboards
                break
            case .paths:
                // Could trigger a tip about paths
                break
            }
        }
    }
    
    // MARK: - Content Unlocking
    
    /// Check if content is unlocked for the current user
    func isContentUnlocked(_ content: UnlockableContent) -> Bool {
        guard let userData = userAccountData else { return false }
        return levelManager.isContentUnlocked(content, userLevel: userData.currentLevel)
    }
    
    /// Get all content unlocked for the current user
    func getAllUnlockedContent() -> [UnlockableContent] {
        guard let userData = userAccountData else { return [] }
        return levelManager.getAllUnlockedContent(upToLevel: userData.currentLevel)
    }
    
    // Centralized user data - AppState is the single source of truth
    var authState: AuthState = .loading
    var userAccountData: UserAccountData?
    var userInventory: UserInventory?
    var isLoadingUserData: Bool = false
    var userDataError: String?
    
    // Cached level info to avoid repeated fetches
    private var cachedLevelInfo: [LevelInfo]?
    
    init() {
        Task {
            await checkAuthenticationStatus()
            await observeAuthStateChanges()
        }
    }
    
    var isAuthenticated: Bool {
        switch authState {
        case .authenticated:
            return true
        default:
            return false
        }
    }
    
    func setMenuItem(_ menuItem: MenuItem) {
        withAnimation {
            selectedMenuItem = menuItem
        }
    }
    
    // MARK: - User Data Management
    
    /// Fetches and caches user account data
    func loadUserData() async {
        await MainActor.run {
            self.isLoadingUserData = true
            self.userDataError = nil
        }
        
        let result = await userDataService.fetchUserAccountData()
        
        switch result {
        case .success(let data):
            await MainActor.run {
                
                self.userAccountData = data
                self.isLoadingUserData = false
                self.userDataError = nil
            }
            await self.loadUserInventory()
        case .failure(let error):
            await MainActor.run {
                self.userAccountData = nil
                self.userInventory = nil
                self.isLoadingUserData = false
                self.userDataError = error.localizedDescription
                print("Failed to load user data: \(error.localizedDescription)")
            }
        }
    }
    
    /// Refreshes user data (useful after workouts or profile changes)
    func refreshUserData() async {
        await loadUserData()
    }
    
    /// Loads user inventory data
    private func loadUserInventory() async {
        do {
            let inventory = try await itemService.fetchUserInventory()
            await MainActor.run {
                self.userInventory = inventory
            }
        } catch {
            print("Failed to load user inventory: \(error.localizedDescription)")
            await MainActor.run {
                self.userInventory = nil
            }
        }
    }
    
    /// Refreshes user inventory (useful after item purchases)
    func refreshUserInventory() async {
        await loadUserInventory()
    }
    
    /// Updates user XP after a workout and checks for level up
    func updateUserXP(additionalXP: Int) async {
        guard let currentData = userAccountData else {
            await refreshUserData()
            return
        }
        
        let result = await levelManager.updateUserXPAndCheckLevelUp(
            currentUserData: currentData,
            additionalXP: additionalXP
        )
        
        switch result {
        case .leveledUp(let notification):
            // Level up notification will be shown automatically via showLevelUpPopup
            await refreshUserData()
        case .noLevelChange:
            await refreshUserData()
        case .error:
            await refreshUserData()
        }
    }
    
    private func getLevelInfo() async throws -> [LevelInfo] {
        let levelInfo: [LevelInfo]
        if let cached = cachedLevelInfo {
            levelInfo = cached
        } else {
            let info = try await userDataService.fetchLevelInfo()
            levelInfo = info
            cachedLevelInfo = info
        }
        return levelInfo
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String) async -> Result<Void, Error> {
        return await userDataService.signUp(email: email, password: password)
    }
    
    func signIn(email: String, password: String) async -> Result<Void, Error> {
        let result = await userDataService.signIn(email: email, password: password)
        if case .success = result {
            await checkAuthenticationStatus()
        }
        return result
    }
    
    func signOut() async -> Result<Void, Error> {
        let result = await userDataService.signOut()
        if case .success = result {
            await MainActor.run {
                self.authState = .unauthenticated
                self.userAccountData = nil
            }
        }
        return result
    }
    
    func resetPassword(email: String) async -> Result<Void, Error> {
        return await userDataService.resetPassword(email: email)
    }
    
    func createProfile(firstName: String, lastName: String, avatarName: String, avatarUrl: String? = nil, profilePictureUrl: String? = nil) async -> Result<Void, Error> {
        let result = await userDataService.createProfile(firstName: firstName, lastName: lastName, avatarName: avatarName, avatarUrl: avatarUrl, profilePictureUrl: profilePictureUrl)
        if case .success = result {
            await checkAuthenticationStatus()
        }
        return result
    }
    
    func updateProfile(firstName: String, lastName: String, avatarName: String, avatarUrl: String? = nil, profilePictureUrl: String? = nil) async -> Result<Void, Error> {
        let result = await userDataService.updateProfile(firstName: firstName, lastName: lastName, avatarName: avatarName, avatarUrl: avatarUrl, profilePictureUrl: profilePictureUrl)
        if case .success = result {
            await refreshUserData()
        }
        return result
    }
    
    // MARK: - Auth State Management
    
    private func checkAuthenticationStatus() async {
        let sessionResult = await userDataService.checkExistingSession()
        
        switch sessionResult {
        case .success(let session):
            if session != nil {
                // We have a valid session, now check if profile exists
                let userDataResult = await userDataService.fetchUserAccountData()
                switch userDataResult {
                case .success(let userData):
                    await MainActor.run {
                        self.authState = .authenticated(hasCompletedOnboarding: true)
                    }
                    Task {
                        await self.missionManager.loadAllMissions(userData.currentLevel)
                    }
                case .failure(let error):
                    if case .profileNotFound = error {
                        // User needs to complete onboarding
                        await MainActor.run {
                            self.userAccountData = nil
                            self.authState = .authenticated(hasCompletedOnboarding: false)
                        }
                    } else {
                        await MainActor.run {
                            self.authState = .error(error)
                        }
                    }
                }
            } else {
                await MainActor.run {
                    self.authState = .unauthenticated
                    self.userAccountData = nil
                }
            }
        case .failure(let error):
            await MainActor.run {
                self.authState = .unauthenticated
                self.userAccountData = nil
            }
        }
    }
    
    private func checkOnboardingStatus(for profile: Profile) -> Bool {
        return !profile.firstName.isEmpty &&
               !profile.lastName.isEmpty &&
               !profile.avatarName.isEmpty
    }
    
    // MARK: - Auth State Observation
    
    private func observeAuthStateChanges() async {
        let authStateStream = userDataService.getAuthStateChanges()
        
        for await (event, session) in authStateStream {
            switch event {
            case .signedIn:
                await checkAuthenticationStatus()
            case .signedOut:
                await MainActor.run {
                    self.authState = .unauthenticated
                    self.userAccountData = nil
                }
            case .tokenRefreshed:
                // Session refreshed, update if needed
                if session != nil && !isAuthenticated {
                    await checkAuthenticationStatus()
                }
            default:
                break
            }
        }
    }
    
    // MARK: - Testing Helpers
    
    #if DEBUG
    func testPathAssignment(_ path: HeroPath) {
        levelManager.pendingPathAssignment = path
        shouldShowPathAssignment = true
    }
    #endif
}
