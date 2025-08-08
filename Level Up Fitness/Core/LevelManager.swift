//
//  LevelManager.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/6/25.
//

import SwiftUI
import FactoryKit
import Supabase

@Observable
@MainActor
class LevelManager {
    @ObservationIgnored @Injected(\.userDataService) var userDataService
    @ObservationIgnored @Injected(\.pathCalculator) var pathCalculator
    
    // Level up notification state
    private(set) var pendingLevelUpNotification: LevelUpNotification?
    
    // Faction selection state
    private(set) var pendingFactionSelection: Bool = false
    
    // Path assignment state
    var pendingPathAssignment: HeroPath?
    
    // Content unlocking
    private var cachedLevelInfo: [LevelInfo]?
    
    init() {}
    
    // MARK: - Level Up Detection & Notification
    
    /// Updates user XP and checks for level up, returns true if user leveled up
    func updateUserXPAndCheckLevelUp(currentUserData: UserAccountData, additionalXP: Int) async -> LevelUpResult {
        do {
            // Get level info from cache or fetch if not available
            let levelInfo = try await getLevelInfo()
            let newXp = currentUserData.totalXP + additionalXP
            let oldLevel = currentUserData.currentLevel
            let newLevel = UserDataService.calculateNewLevel(currentXp: newXp, levelInfo: levelInfo)
            
            // Update the database
            try await client
                .from("xp_levels")
                .update([
                    "xp": newXp,
                    "current_level": newLevel
                ])
                .eq("user_id", value: currentUserData.profile.id)
                .execute()
            
            // Check if user leveled up
            if newLevel > oldLevel {
                let unlockedContent = getUnlockedContent(newLevel: newLevel)
                
                // Auto-assign/recalculate path at level 4 and every 5 levels after (9, 14, 19, etc.)
                if shouldRecalculatePath(newLevel: newLevel) {
                    do {
                        let assignedPath = try await pathCalculator.calculatePath(for: currentUserData.profile.id)
                        try await updateUserPath(assignedPath)
                        
                        // Store the assigned path for display after level up popup
                        pendingPathAssignment = assignedPath
                    } catch {
                        print("Failed to calculate/assign path: \(error)")
                    }
                }
                
                let levelUpNotification = LevelUpNotification(
                    fromLevel: oldLevel,
                    toLevel: newLevel,
                    unlockedContent: unlockedContent
                )
                
                // Store the notification to be shown
                pendingLevelUpNotification = levelUpNotification
                
                // Faction selection timing will be handled by AppState
                // No need to set pendingFactionSelection here anymore
                
                return .leveledUp(levelUpNotification)
            } else {
                return .noLevelChange(newXP: newXp)
            }
            
        } catch {
            return .error(error)
        }
    }
    
    /// Dismisses the current level up notification
    func dismissLevelUpNotification() {
        pendingLevelUpNotification = nil
    }
    
    /// Shows faction selection (called after level up popup is dismissed if factions were unlocked)
    func showFactionSelectionIfNeeded() {
        // Faction selection will be shown via pendingFactionSelection
    }
    
    /// Dismisses faction selection
    func dismissFactionSelection() {
        pendingFactionSelection = false
    }
    
    /// Dismisses path assignment
    func dismissPathAssignment() {
        pendingPathAssignment = nil
    }
    
    /// Completes faction selection
    func completeFactionSelection(_ faction: Faction) async {
        let result = await userDataService.updateFaction(faction)
        switch result {
        case .success:
            pendingFactionSelection = false
        case .failure(let error):
            print("Failed to save faction: \(error)")
            // Still dismiss to prevent UI blocking
            pendingFactionSelection = false
        }
    }
    
    /// Shows the level up notification (useful for manual triggering)
    func showLevelUpNotification(_ notification: LevelUpNotification) {
        pendingLevelUpNotification = notification
    }
    
    // MARK: - Content Unlocking
    
    /// Check if content is unlocked at the given level
    func isContentUnlocked(_ content: UnlockableContent, userLevel: Int) -> Bool {
        return userLevel >= content.requiredLevel
    }
    
    /// Get all content that becomes unlocked at a specific level
    private func getUnlockedContent(newLevel: Int) -> [UnlockableContent] {
        return UnlockableContent.allContent.filter { $0.requiredLevel == newLevel }
    }
    
    /// Get all content unlocked up to a specific level
    func getAllUnlockedContent(upToLevel: Int) -> [UnlockableContent] {
        return UnlockableContent.allContent.filter { $0.requiredLevel <= upToLevel }
    }
    
    // MARK: - Level Info Management
    
    private func getLevelInfo() async throws -> [LevelInfo] {
        if let cached = cachedLevelInfo {
            return cached
        } else {
            let info = try await userDataService.fetchLevelInfo()
            cachedLevelInfo = info
            return info
        }
    }
    
    /// Clear cached level info (useful for testing or data refresh)
    func clearLevelInfoCache() {
        cachedLevelInfo = nil
    }
    
    // MARK: - Path Management
    
    /// Update user's path in the database
    private func updateUserPath(_ path: HeroPath) async throws {
        try await client
            .from("profiles")
            .update(["path": path.rawValue])
            .eq("id", value: try await client.auth.session.user.id)
            .execute()
    }
    
    /// Determine if path should be recalculated at the given level
    private func shouldRecalculatePath(newLevel: Int) -> Bool {
        // Initial path assignment at level 4
        if newLevel == 4 {
            return true
        }
        
        // Recalculate every 5 levels after level 4 (9, 14, 19, 24, etc.)
        if newLevel > 4 && (newLevel - 4) % 5 == 0 {
            return true
        }
        
        return false
    }
}

// MARK: - Models

struct LevelUpNotification {
    let fromLevel: Int
    let toLevel: Int
    let unlockedContent: [UnlockableContent]
    let timestamp: Date = Date()
}

enum LevelUpResult {
    case leveledUp(LevelUpNotification)
    case noLevelChange(newXP: Int)
    case error(Error)
}

enum UnlockableContent: CaseIterable {
    case missions
    case factions
    case factionLeaderboards
    case paths
    
    var requiredLevel: Int {
        switch self {
        case .missions:
            return 2
        case .factions, .factionLeaderboards:
            return 3
        case .paths:
            return 4
        }
    }
    
    var displayName: String {
        switch self {
        case .missions:
            return "Missions"
        case .factions:
            return "Factions"
        case .factionLeaderboards:
            return "Faction Leaderboards"
        case .paths:
            return "Paths"
        }
    }
    
    var description: String {
        switch self {
        case .missions:
            return "Complete missions to earn bonus rewards"
        case .factions:
            return "Join a faction to fight and compete for influence and power within the Nexus."
        case .factionLeaderboards:
            return "Compete in faction leaderboards to earn rewards and climb the ranks."
        case .paths:
            return "Start down your Path that grants mission bonuses and unique group benefits."
        }
    }
    
    var imageName: String {
        switch self {
        case .missions:
            return "missions_icon"
        case .factions:
            return "faction_icon"
        case .factionLeaderboards:
            return "faction_icon"
        case .paths:
            return "champion_icon"
        }
    }
    
    static var allContent: [UnlockableContent] {
        return UnlockableContent.allCases
    }
}
