import Foundation
import Supabase
import FactoryKit

// MARK: - Error Types

enum WorkoutError: LocalizedError {
    case notAuthenticated
    case networkError(String)
    case databaseError(String)
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to perform this action"
        case .networkError(let message):
            return "Network error: \(message)"
        case .databaseError(let message):
            return "Database error: \(message)"
        case .unknownError(let message):
            return message
        }
    }
    
    init(message: String) {
        self = .unknownError(message)
    }
}

// MARK: - Protocol

protocol WorkoutServiceProtocol {
    func saveWorkout(duration: Int, types: [String]) async -> Result<Workout, WorkoutError>
    func updateWorkout(workoutId: String, duration: Int, types: [String]) async -> Result<Void, WorkoutError>
    func fetchTodaysWorkout() async -> Result<Workout?, WorkoutError>
    func fetchTodaysWorkouts() async -> Result<[Workout], WorkoutError>
    func fetchTodaysTotalMinutes() async -> Result<Int, WorkoutError>
    func fetchCurrentStreak() async -> Result<Int, WorkoutError>
}

// MARK: - Implementation

@MainActor
class WorkoutService: WorkoutServiceProtocol {
    @ObservationIgnored @Injected(\.appState) var appState
    init() {}
    
    private var isAuthenticated: Bool {
        return appState.isAuthenticated
    }
    
    private var currentUserId: UUID? {
        return client.auth.currentUser?.id
    }
    
    func saveWorkout(duration: Int, types: [String]) async -> Result<Workout, WorkoutError> {
        guard isAuthenticated, let userId = currentUserId else {
            return .failure(.notAuthenticated)
        }
        do {
            let now = Date()
            let workout = Workout(
                userId: userId.uuidString,
                duration: duration,
                workoutTypes: types,
                date: now,
                xpEarned: await calculateXP(duration: duration)
            )
            
            // Insert into the workouts table
            try await client.from("workouts")
                .insert(workout)
                .execute()
            
            // Update the user's streak only if this is the first workout today
            let isFirstWorkoutToday = await isFirstWorkoutOfDay(userId: userId)
            if isFirstWorkoutToday {
                _ = await updateStreak(userId: userId)
            }
            
            return .success(workout)
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func updateWorkout(workoutId: String, duration: Int, types: [String]) async -> Result<Void, WorkoutError> {
        guard isAuthenticated, let userId = currentUserId else {
            return .failure(.notAuthenticated)
        }
        
        do {
            let now = Date()
            let workout = Workout(
                id: workoutId,
                userId: userId.uuidString,
                duration: duration,
                workoutTypes: types,
                date: now,
                xpEarned: await calculateXP(duration: duration)
            )
            
            // Update the workout in the database
            try await client.from("workouts")
                .update(workout)
                .eq("id", value: workoutId)
                .execute()
            
            return .success(())
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func fetchTodaysWorkout() async -> Result<Workout?, WorkoutError> {
        let result = await fetchTodaysWorkouts()
        switch result {
        case .success(let workouts):
            return .success(workouts.first)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func fetchTodaysWorkouts() async -> Result<[Workout], WorkoutError> {
        guard isAuthenticated, let userId = currentUserId else {
            return .failure(.notAuthenticated)
        }
        
        do {
            // Get today's date range (midnight to 11:59:59 PM)
            let calendar = Calendar.current
            let now = Date()
            let today = calendar.startOfDay(for: now)
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            // Format dates for the query
            let formatter = ISO8601DateFormatter()
            let todayString = formatter.string(from: today)
            let tomorrowString = formatter.string(from: tomorrow)
            
            // Query for all workouts from today
            let workouts: [Workout] = try await client.from("workouts")
                .select()
                .eq("user_id", value: userId.uuidString)
                .gte("date", value: todayString)
                .lt("date", value: tomorrowString)
                .order("date", ascending: false)
                .execute()
                .value
            
            // Additional client-side validation to ensure workouts are from today
            let validWorkouts = workouts.filter { workout in
                let workoutDate = workout.date
                return calendar.isDate(workoutDate, inSameDayAs: now) &&
                       workoutDate >= today &&
                       workoutDate < tomorrow
            }
            
            return .success(validWorkouts)
            
        } catch {
            return .failure(.databaseError(error.localizedDescription))
        }
    }
    
    func fetchTodaysTotalMinutes() async -> Result<Int, WorkoutError> {
        let result = await fetchTodaysWorkouts()
        switch result {
        case .success(let workouts):
            let totalMinutes = workouts.reduce(0) { $0 + $1.duration }
            return .success(totalMinutes)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func fetchCurrentStreak() async -> Result<Int, WorkoutError> {
        guard isAuthenticated, let userId = currentUserId else {
            return .failure(.notAuthenticated)
        }
        
        do {
            // Get the streak from the streaks table
            let streak: UserStreak = try await client.from("streaks")
                .select()
                .eq("user_id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            // Check if the streak is still valid (workout within last 48 hours)
            if let lastWorkoutDate = streak.lastWorkoutDate {
                let calendar = Calendar.current
                let now = Date()
                let hoursSinceLastWorkout = calendar.dateComponents([.hour], from: lastWorkoutDate, to: now).hour ?? 0
                
                if hoursSinceLastWorkout > 48 {
                    // It's been more than 48 hours, streak is broken
                    return .success(0)
                }
            }
            
            return .success(streak.currentStreak)
        } catch {
            // If no streak record exists yet, return 0
            return .success(0)
        }
    }
    
    // MARK: - Private Methods
    
    private func calculateXP(duration: Int) async -> Int {
        // Base XP: 1 XP per minute, capped at 60
        let baseXP = min(duration, 60)
        
        // Get equipment bonus from AppState
        let equipmentBonus = appState.userInventory?.totalXPBonus ?? 0.0
        
        // Apply equipment bonus: baseXP * (1 + bonus/100)
        let bonusMultiplier = 1.0 + (equipmentBonus / 100.0)
        let totalXP = Double(baseXP) * bonusMultiplier
        
        return Int(round(totalXP))
    }
    
    private func isFirstWorkoutOfDay(userId: UUID) async -> Bool {
        do {
            // Get today's date range (midnight to 11:59:59 PM)
            let calendar = Calendar.current
            let now = Date()
            let today = calendar.startOfDay(for: now)
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            // Format dates for the query
            let formatter = ISO8601DateFormatter()
            let todayString = formatter.string(from: today)
            let tomorrowString = formatter.string(from: tomorrow)
            
            // Check if there are any existing workouts for today
            let existingWorkouts: [Workout] = try await client.from("workouts")
                .select("id") // Only select id to minimize data transfer
                .eq("user_id", value: userId.uuidString)
                .gte("date", value: todayString)
                .lt("date", value: tomorrowString)
                .execute()
                .value
            
            // If no existing workouts, this is the first workout of the day
            return existingWorkouts.isEmpty
            
        } catch {
            print("Error checking if first workout of day: \(error.localizedDescription)")
            // If we can't determine, assume it's the first to be safe with streak counting
            return true
        }
    }
    
    private func updateStreak(userId: UUID) async -> Int {
        do {
            // Get the most recent workouts to determine streak status
            let workouts: [Workout] = try await client.from("workouts")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("date", ascending: false)
                .limit(2)
                .execute()
                .value
            
            let today = Date()
            
            // Get current streak record or create if it doesn't exist
            var currentStreak = 0
            var longestStreak = 0
            var lastWorkoutDate: Date? = nil
            
            // Try to get existing streak record
            do {
                let streak: UserStreak = try await client.from("streaks")
                    .select()
                    .eq("user_id", value: userId.uuidString)
                    .single()
                    .execute()
                    .value
    
                currentStreak = streak.currentStreak
                longestStreak = streak.longestStreak
                lastWorkoutDate = streak.lastWorkoutDate
                
                // Check if we need to update the streak
                if let lastDate = lastWorkoutDate, workouts.count > 0 {
                    let calendar = Calendar.current
                    
                    // Check if we already updated the streak today to prevent double counting
                    let isLastUpdateToday = calendar.isDate(lastDate, inSameDayAs: today)
                    
                    if !isLastUpdateToday {
                        // Calculate hours since last workout
                        let hoursSinceLastWorkout = calendar.dateComponents([.hour], from: lastDate, to: today).hour ?? 0
                        
                        if hoursSinceLastWorkout <= 48 {
                            // Within 48 hours - streak continues
                            currentStreak += 1
                            
                            // Update longest streak if needed
                            if currentStreak > longestStreak {
                                longestStreak = currentStreak
                            }
                        } else {
                            // More than 48 hours - streak resets to 1
                            currentStreak = 1
                        }
                    }
                    // If last update was today, don't modify the streak (prevents double counting)
                }
            } catch {
                // No streak record exists yet, we'll create one
                print("No existing streak record: \(error.localizedDescription)")
            }
            
            // Update or create streak record
            let streakData: [String: AnyJSON] = [
                "user_id": .string(userId.uuidString),
                "current_streak": .integer(currentStreak),
                "longest_streak": .integer(longestStreak),
                "last_workout_date": .string(ISO8601DateFormatter().string(from: today))
            ]
            
            // Try to upsert the streak record
            try await client.from("streaks")
                .upsert(streakData)
                .execute()
            
            return currentStreak
        } catch {
            print("Failed to update streak: \(error.localizedDescription)")
            return 0
        }
    }
}

// MARK: - Mock Service

class MockWorkoutService: WorkoutServiceProtocol {
    var shouldFail = false
    var mockTodaysWorkouts: [Workout] = []
    var mockStreak = 5
    
    init() {
        // Initialize with some mock workouts totaling 35 minutes (allowing 25 more)
        mockTodaysWorkouts = [
            Workout(
                userId: UUID().uuidString,
                duration: 20,
                workoutTypes: ["cardio"],
                date: Date(),
                xpEarned: 20
            ),
            Workout(
                userId: UUID().uuidString,
                duration: 15,
                workoutTypes: ["strength"],
                date: Date(),
                xpEarned: 15
            )
        ]
    }
    func saveWorkout(duration: Int, types: [String]) async -> Result<Workout, WorkoutError> {
        if shouldFail {
            return .failure(.unknownError("Mock save failed"))
        }
        
        // Simulate a successful save by adding a new mock workout
        let newWorkout = Workout(
            userId: UUID().uuidString,
            duration: duration,
            workoutTypes: types,
            date: Date(),
            xpEarned: duration // Mock service uses simple calculation
        )
        mockTodaysWorkouts.append(newWorkout)
        
        return .success(newWorkout)
    }
    
    func updateWorkout(workoutId: String, duration: Int, types: [String]) async -> Result<Void, WorkoutError> {
        if shouldFail {
            return .failure(.unknownError("Mock update failed"))
        }
        return .success(())
    }
    
    func fetchTodaysWorkout() async -> Result<Workout?, WorkoutError> {
        if shouldFail {
            return .failure(.unknownError("Mock fetch failed"))
        }
        return .success(mockTodaysWorkouts.first)
    }
    
    func fetchTodaysWorkouts() async -> Result<[Workout], WorkoutError> {
        if shouldFail {
            return .failure(.unknownError("Mock fetch failed"))
        }
        return .success(mockTodaysWorkouts)
    }
    
    func fetchTodaysTotalMinutes() async -> Result<Int, WorkoutError> {
        if shouldFail {
            return .failure(.unknownError("Mock fetch failed"))
        }
        let totalMinutes = mockTodaysWorkouts.reduce(0) { $0 + $1.duration }
        return .success(totalMinutes)
    }
    
    func fetchCurrentStreak() async -> Result<Int, WorkoutError> {
        if shouldFail {
            return .failure(.unknownError("Mock streak fetch failed"))
        }
        return .success(mockStreak)
    }
}
