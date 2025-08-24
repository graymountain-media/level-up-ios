//
//  Test.swift
//  Level Up
//
//  Created by Jake Gray on 8/18/25.
//

import Foundation

struct StreakRecalculationResult {
    let userId: UUID
    let currentStreakOld: Int
    let currentStreakNew: Int
    let longestStreakOld: Int
    let longestStreakNew: Int
    let lastWorkoutDateOld: Date?
    let lastWorkoutDateNew: Date?
    let changeType: String
}

func recalculateAllStreaks() async throws -> [StreakRecalculationResult] {
    var results: [StreakRecalculationResult] = []
    let today = Date()
    let calendar = Calendar.current
    
    // Get all user IDs from profiles
    let profiles: [Profile] = try await client.from("profiles")
        .select("id")
        .execute()
        .value
    
    // Loop through each user
    for profile in profiles {
        let userId = profile.id
        var newCurrentStreak = 0
        var newLongestStreak = 0
        var newLastDate: Date? = nil
        
        // Get workouts for this user in chronological order
        let workouts: [Workout] = try await client.from("workouts")
            .select("date")
            .eq("user_id", value: userId.uuidString)
            .order("date", ascending: true)
            .execute()
            .value
        
        // Get unique workout dates
        let uniqueWorkoutDates = Array(Set(workouts.map { calendar.startOfDay(for: $0.date) }))
            .sorted()
        
        // Process each workout date
        for workoutDate in uniqueWorkoutDates {
            if newLastDate == nil {
                // First workout
                newCurrentStreak = 1
                newLongestStreak = 1
            } else {
                // Check if within 2 days
                let daysDifference = calendar.dateComponents([.day], from: newLastDate!, to: workoutDate).day ?? 0
                
                if daysDifference <= 2 {
                    newCurrentStreak += 1
                    if newCurrentStreak > newLongestStreak {
                        newLongestStreak = newCurrentStreak
                    }
                } else {
                    // Streak broken, reset to 1
                    newCurrentStreak = 1
                }
            }
            
            newLastDate = workoutDate
        }
        
        // Check if current streak is still valid (within 2 days of today)
        if let lastDate = newLastDate {
            let daysSinceLastWorkout = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
            if daysSinceLastWorkout > 2 {
                newCurrentStreak = 0
            }
        }
        
        // Get existing streak data
        do {
            let existingStreak: UserStreak = try await client.from("streaks")
                .select()
                .eq("user_id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            // Compare with existing values
            let existingLastDate = existingStreak.lastWorkoutDate != nil ?
            calendar.startOfDay(for: existingStreak.lastWorkoutDate!) : nil
            
            if existingStreak.currentStreak != newCurrentStreak ||
                existingStreak.longestStreak != newLongestStreak ||
                existingLastDate != newLastDate {
                
                results.append(StreakRecalculationResult(
                    userId: userId,
                    currentStreakOld: existingStreak.currentStreak,
                    currentStreakNew: newCurrentStreak,
                    longestStreakOld: existingStreak.longestStreak,
                    longestStreakNew: newLongestStreak,
                    lastWorkoutDateOld: existingLastDate,
                    lastWorkoutDateNew: newLastDate,
                    changeType: "UPDATED"
                ))
            } else {
                results.append(StreakRecalculationResult(
                    userId: userId,
                    currentStreakOld: existingStreak.currentStreak,
                    currentStreakNew: newCurrentStreak,
                    longestStreakOld: existingStreak.longestStreak,
                    longestStreakNew: newLongestStreak,
                    lastWorkoutDateOld: existingLastDate,
                    lastWorkoutDateNew: newLastDate,
                    changeType: "NO_CHANGE"
                ))
            }
            
        } catch {
            // No streak record exists yet
            if newLastDate != nil {
                results.append(StreakRecalculationResult(
                    userId: userId,
                    currentStreakOld: 0,
                    currentStreakNew: newCurrentStreak,
                    longestStreakOld: 0,
                    longestStreakNew: newLongestStreak,
                    lastWorkoutDateOld: nil,
                    lastWorkoutDateNew: newLastDate,
                    changeType: "NEW_RECORD"
                ))
            }
        }
    }
    
    return results
}
