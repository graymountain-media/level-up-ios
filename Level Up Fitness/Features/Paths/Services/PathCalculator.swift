//
//  PathCalculator.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/8/25.
//

import Foundation
import FactoryKit

// MARK: - Path Calculator Service

@MainActor
class PathCalculator {
    @ObservationIgnored @Injected(\.userDataService) var userDataService
    
    // MARK: - Path Calculation
    
    /// Calculate the appropriate path for a user based on their workout history
    func calculatePath(for userId: UUID) async throws -> HeroPath {
        let stats = try await fetchWorkoutTypeStats(for: userId)
        return determinePath(from: stats)
    }
    
    /// Calculate path from workout type statistics
    func determinePath(from stats: WorkoutTypeStats) -> HeroPath {
        // Rule 1: Champion Path - All three types ~33% each
        if stats.hasChampionDistribution {
            return .champion
        }
        
        // Rule 2: Single dominant type (>= 80%)
        if stats.hasSingleDominantType {
            switch stats.mostDominant {
            case .strength:
                return .brute
            case .cardio:
                return .ranger
            case .functional:
                return .sentinel
            }
        }
        
        // Rule 3: Hybrid paths based on top 2 workout types
        return determineHybridPath(from: stats)
    }
    
    // MARK: - Private Methods
    
    private func fetchWorkoutTypeStats(for userId: UUID) async throws -> WorkoutTypeStats {
        return try await userDataService.fetchWorkoutTypeStats(for: userId)
    }
    
    private func determineHybridPath(from stats: WorkoutTypeStats) -> HeroPath {
        let sorted = stats.sortedByPercentage
        guard sorted.count >= 2 else { return .brute } // fallback
        
        let primary = sorted[0].0
        let secondary = sorted[1].0
        let tertiary = sorted.count > 2 ? sorted[2].0 : nil
        
        // Check for tie between 2nd and 3rd place
        if let tertiary = tertiary,
           sorted.count >= 3,
           abs(sorted[1].1 - sorted[2].1) < 0.1 { // Within 0.1% is considered a tie
            
            // Random selection between hybrid paths that include the primary type
            let validPaths = getHybridPathsForPrimary(primary)
            return validPaths.randomElement() ?? .brute
        }
        
        // Standard hybrid path selection
        return getHybridPath(primary: primary, secondary: secondary)
    }
    
    private func getHybridPath(primary: WorkoutType, secondary: WorkoutType) -> HeroPath {
        let combination = Set([primary, secondary])
        
        switch combination {
        case Set([.strength, .cardio]):
            return .hunter
        case Set([.strength, .functional]):
            return .juggernaut
        case Set([.functional, .cardio]):
            return .strider
        default:
            return .brute // fallback
        }
    }
    
    private func getHybridPathsForPrimary(_ primary: WorkoutType) -> [HeroPath] {
        switch primary {
        case .strength:
            return [.hunter, .juggernaut]
        case .cardio:
            return [.hunter, .strider]
        case .functional:
            return [.juggernaut, .strider]
        }
    }
}
