//
//  WorkoutTypeStats.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/8/25.
//

import Foundation

// MARK: - Workout Type Statistics

struct WorkoutTypeStats {
    let strengthPercentage: Double
    let cardioPercentage: Double
    let functionalPercentage: Double
    let totalWorkouts: Int
    
    var mostDominant: WorkoutType {
        let percentages = [
            (WorkoutType.strength, strengthPercentage),
            (WorkoutType.cardio, cardioPercentage),
            (WorkoutType.functional, functionalPercentage)
        ]
        return percentages.max(by: { $0.1 < $1.1 })?.0 ?? .strength
    }
    
    var sortedByPercentage: [(WorkoutType, Double)] {
        let percentages = [
            (WorkoutType.strength, strengthPercentage),
            (WorkoutType.cardio, cardioPercentage),
            (WorkoutType.functional, functionalPercentage)
        ]
        return percentages.sorted(by: { $0.1 > $1.1 })
    }
    
    var hasChampionDistribution: Bool {
        // Champion requires all three types to be between 33-34%
        let tolerance = 1.0
        let target = 33.33
        
        return abs(strengthPercentage - target) <= tolerance &&
               abs(cardioPercentage - target) <= tolerance &&
               abs(functionalPercentage - target) <= tolerance
    }
    
    var hasSingleDominantType: Bool {
        return mostDominant == .strength ? strengthPercentage >= 80.0 :
               mostDominant == .cardio ? cardioPercentage >= 80.0 :
               functionalPercentage >= 80.0
    }
}