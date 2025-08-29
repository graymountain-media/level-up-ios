//
//  LeaderboardViewModel.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/18/25.
//

import Foundation
import Combine
import Supabase
import FactoryKit

@MainActor
@Observable
class LeaderboardViewModel {
    // MARK: - Properties
    @ObservationIgnored @Injected(\.leaderboardService) var leaderboardService
    @ObservationIgnored @Injected(\.appState) var appState
    // State properties
    var leaderboardEntries: [any LeaderboardEntry] = []
    var isLoading = true
    var errorMessage: String?
    var showError = false
    var currentUserRank: Int?
    
    // MARK: - Public Methods
    
    /// Fetches the leaderboard data
    func fetchLeaderboard(for tab: LeaderboardTab) async {
        isLoading = true
        errorMessage = nil
        showError = false
        
        var result: Result<[any LeaderboardEntry], LeaderboardError>
        switch tab {
        case .xp:
            result = await leaderboardService.fetchLeaderboard()
        case .streaks:
            result = await leaderboardService.fetchStreakLeaderboard()
        case .factions:
            result = await leaderboardService.fetchFactionLeaderboard()
        }
        
        switch result {
        case .success(let entries):
            await MainActor.run {
                self.leaderboardEntries = filterEmptyEntries(entries, for: tab)
                self.isLoading = false
            }
            
        case .failure(let error):
            setError("Failed to load leaderboard: \(error.localizedDescription)")
        }
    }
    
    private func filterEmptyEntries(_ entries: [any LeaderboardEntry], for tab: LeaderboardTab) -> [any LeaderboardEntry] {
        if tab == .xp {
            return entries.filter {
                ($0 as? XpLeaderboardEntry)?.xp != 0 || $0.userId == client.auth.currentUser?.id
            }
        } else if tab == .streaks {
            return entries.filter {
                ($0 as? StreakLeaderboardEntry)?.currentStreak != 0 || $0.userId == client.auth.currentUser?.id
            }
        } else {
            return entries
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
