import Foundation
import Supabase
import FactoryKit

@MainActor
@Observable
class AvatarViewModel {
    // MARK: - Properties
    @ObservationIgnored @Injected(\.avatarService) var avatarService
    
    // State properties
    var avatarData: AvatarData?
    var isLoading = true
    var errorMessage: String?
    var showError = false
    
    // MARK: - Computed Properties
    
    var displayName: String {
        guard let profile = avatarData?.profile else { return "Unknown Hero" }
        return "\(profile.firstName) \(profile.lastName)"
    }
    
    var currentLevel: Int {
        return avatarData?.currentLevel ?? 1
    }
    
    var xpToNextLevel: Int {
        return avatarData?.xpToNextLevel ?? 100
    }
    
    var progressToNextLevel: Double {
        return avatarData?.progressToNextLevel ?? 0.0
    }
    
    var currentStreak: Int {
        return avatarData?.currentStreak ?? 0
    }
    
    var totalXP: Int {
        return avatarData?.currentXP ?? 0
    }
    
    var credits: Int {
        return avatarData?.profile.credits ?? 0
    }
    
    // MARK: - Public Methods
    
    /// Fetches all avatar data including profile, XP, level, and streak
    func fetchAvatarData() async {
        isLoading = true
        errorMessage = nil
        showError = false
        
        let result = await avatarService.fetchAvatarData()
        
        switch result {
        case .success(let data):
            await MainActor.run {
                self.avatarData = data
                self.isLoading = false
            }
            
        case .failure(let error):
            setError("Failed to load avatar data: \(error.localizedDescription)")
        }
    }
    
    /// Refreshes only the XP and level data
    func refreshXPData() async {
        let result = await avatarService.fetchUserXP()
        
        switch result {
        case .success(let totalXP):
            if let currentData = avatarData {
                let currentLevel = AvatarService.levelForXP(totalXP)
                let xpToNext = AvatarService.xpForLevel(currentLevel + 1) - totalXP
                
                await MainActor.run {
                    self.avatarData = AvatarData(
                        profile: currentData.profile,
                        currentXP: totalXP,
                        currentLevel: currentLevel,
                        xpToNextLevel: xpToNext,
                        currentStreak: currentData.currentStreak
                    )
                }
            }
            
        case .failure(let error):
            print("Failed to refresh XP data: \(error.localizedDescription)")
        }
    }
    
    /// Refreshes only the streak data
    func refreshStreakData() async {
        let result = await avatarService.fetchCurrentStreak()
        
        switch result {
        case .success(let streak):
            if let currentData = avatarData {
                await MainActor.run {
                    self.avatarData = AvatarData(
                        profile: currentData.profile,
                        currentXP: currentData.currentXP,
                        currentLevel: currentData.currentLevel,
                        xpToNextLevel: currentData.xpToNextLevel,
                        currentStreak: streak
                    )
                }
            }
            
        case .failure(let error):
            print("Failed to refresh streak data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Sets an error message and shows the error alert
    /// - Parameter message: Error message to display
    private func setError(_ message: String) {
        Task { @MainActor in
            isLoading = false
            errorMessage = message
            showError = true
        }
    }
}