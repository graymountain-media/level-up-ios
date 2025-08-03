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

@Observable
@MainActor
class AppState {
    @ObservationIgnored @Injected(\.missionManager) var missionManager
    @ObservationIgnored @Injected(\.userDataService) var userDataService
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
    
    // Centralized user data - AppState is the single source of truth
    var authState: AuthState = .loading
    var userAccountData: UserAccountData?
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
        
        await MainActor.run {
            switch result {
            case .success(let data):
                self.userAccountData = data
                self.isLoadingUserData = false
                self.userDataError = nil
                
            case .failure(let error):
                self.userAccountData = nil
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
    
    /// Updates user XP after a workout and recalculates level/progress
    func updateUserXP(additionalXP: Int) async {
        guard let currentData = userAccountData else {
            await refreshUserData()
            return
        }
        
        do {
            // Get level info from cache or fetch if not available
            let levelInfo = try await getLevelInfo()
            let newXp = currentData.totalXP + additionalXP
            let newLevel = UserDataService.calculateNewLevel(currentXp: newXp, levelInfo: levelInfo)
            try await client
                .from("xp_levels")
                .update([
                    "xp": newXp,
                    "current_level": newLevel
                ])
                .eq("user_id", value: currentData.profile.id)
                .execute()
            // Update the cached data immediately for responsive UI
            
            await refreshUserData()
        } catch {
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
}
