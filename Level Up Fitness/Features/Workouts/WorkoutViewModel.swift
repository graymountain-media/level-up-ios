import Foundation
import Supabase
import FactoryKit

@MainActor
@Observable
class WorkoutViewModel {
    // MARK: - Properties
    @ObservationIgnored @Injected(\.workoutService) var workoutService
    
    // State properties
    var isLoading = true
    var errorMessage: String?
    var showError = false
    var saveSuccess = false
    
    // MARK: - Public Methods
    
    /// Saves a workout to the database
    /// - Parameters:
    ///   - duration: Duration of the workout in minutes
    ///   - type: Type of workout (cardio, strength, etc.)
    ///   - intensity: Intensity level of the workout
    func saveWorkout(duration: Int, types: [String]) async {
        isLoading = true
        errorMessage = nil
        showError = false
        saveSuccess = false
        let result = await workoutService.saveWorkout(duration: duration, types: types)
        switch result {
        case .success:
            await MainActor.run {
                isLoading = false
                saveSuccess = true
            }
        case .failure(let error):
            setError("Failed to save workout: \(error.localizedDescription)")
        }
    }
    
    /// Updates an existing workout in the database
    /// - Parameters:
    ///   - workoutId: ID of the workout to update
    ///   - duration: New duration in minutes
    ///   - type: New workout type
    ///   - intensity: New intensity level
    func updateWorkout(workoutId: String, duration: Int, types: [String]) async {
        isLoading = true
        errorMessage = nil
        showError = false
        saveSuccess = false
        
        let result = await workoutService.updateWorkout(workoutId: workoutId, duration: duration, types: types)
        
        switch result {
        case .success:
            await MainActor.run {
                isLoading = false
                saveSuccess = true
            }
        case .failure(let error):
            setError("Failed to update workout: \(error.localizedDescription)")
        }
    }
    
    /// Fetches today's workout if it exists
    /// - Returns: The workout for today or nil if none exists
    func fetchTodaysWorkout() async -> Workout? {
        isLoading = true
        
        let result = await workoutService.fetchTodaysWorkout()
        
        await MainActor.run {
            isLoading = false
        }
        
        switch result {
        case .success(let workout):
            return workout
        case .failure(let error):
            self.errorMessage = "Failed to fetch today's workout: \(error.localizedDescription)"
            self.showError = true
            return nil
        }
    }
    
    /// Fetches the current workout streak
    /// - Returns: The current streak count
    func fetchCurrentStreak() async -> Int {
        let result = await workoutService.fetchCurrentStreak()
        
        switch result {
        case .success(let streak):
            return streak
        case .failure(let error):
            print("Failed to fetch streak: \(error.localizedDescription)")
            return 0
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
            saveSuccess = false
        }
    }
}

// MARK: - Models

struct Workout: Codable, Identifiable {
    let id: String
    let userId: String
    let duration: Int
    let workoutTypes: [String]
    let date: Date
    let xpEarned: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case duration
        case workoutTypes = "type"
        case date
        case xpEarned = "xp_earned"
    }
    
    init(id: String = UUID().uuidString, userId: String = UUID().uuidString, duration: Int, workoutTypes: [String], date: Date = Date(), xpEarned: Int) {
        self.id = id
        self.userId = userId
        self.duration = duration
        self.workoutTypes = workoutTypes
        self.date = date
        self.xpEarned = xpEarned
    }
    
    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<Workout.CodingKeys> = try decoder.container(keyedBy: Workout.CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: Workout.CodingKeys.id)
        self.userId = try container.decode(String.self, forKey: Workout.CodingKeys.userId)
        self.duration = try container.decode(Int.self, forKey: Workout.CodingKeys.duration)
        self.workoutTypes = try container.decode([String].self, forKey: Workout.CodingKeys.workoutTypes)
        let dateString = try container.decode(String.self, forKey: Workout.CodingKeys.date)
        self.date = ISO8601DateFormatter().date(from: dateString) ?? Date()
        self.xpEarned = try container.decode(Int.self, forKey: Workout.CodingKeys.xpEarned)
        
    }
    
    func encode(to encoder: any Encoder) throws {
        var container: KeyedEncodingContainer<Workout.CodingKeys> = encoder.container(keyedBy: Workout.CodingKeys.self)
        
        try container.encode(self.id, forKey: Workout.CodingKeys.id)
        try container.encode(self.userId, forKey: Workout.CodingKeys.userId)
        try container.encode(self.duration, forKey: Workout.CodingKeys.duration)
        try container.encode(self.workoutTypes, forKey: Workout.CodingKeys.workoutTypes)
        let dateString = ISO8601DateFormatter().string(from: self.date)
        try container.encode(dateString, forKey: Workout.CodingKeys.date)
        try container.encode(self.xpEarned, forKey: Workout.CodingKeys.xpEarned)
    }
}

struct UserStreak: Codable {
    let userId: UUID
    let currentStreak: Int
    let longestStreak: Int
    let lastWorkoutDate: Date?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case lastWorkoutDate = "last_workout_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<UserStreak.CodingKeys> = try decoder.container(keyedBy: UserStreak.CodingKeys.self)
        
        self.userId = try container.decode(UUID.self, forKey: UserStreak.CodingKeys.userId)
        self.currentStreak = try container.decode(Int.self, forKey: UserStreak.CodingKeys.currentStreak)
        self.longestStreak = try container.decode(Int.self, forKey: UserStreak.CodingKeys.longestStreak)
        let dateString = try container.decodeIfPresent(String.self, forKey: UserStreak.CodingKeys.lastWorkoutDate)
        self.lastWorkoutDate = ISO8601DateFormatter().date(from: dateString ?? "") ?? Date()
        self.createdAt = try container.decode(Date.self, forKey: UserStreak.CodingKeys.createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: UserStreak.CodingKeys.updatedAt)
        
    }
    
    func encode(to encoder: any Encoder) throws {
        var container: KeyedEncodingContainer<UserStreak.CodingKeys> = encoder.container(keyedBy: UserStreak.CodingKeys.self)
        
        try container.encode(self.userId, forKey: UserStreak.CodingKeys.userId)
        try container.encode(self.currentStreak, forKey: UserStreak.CodingKeys.currentStreak)
        try container.encode(self.longestStreak, forKey: UserStreak.CodingKeys.longestStreak)
        let dateString = ISO8601DateFormatter().string(from: self.lastWorkoutDate ?? Date())
        try container.encodeIfPresent(dateString, forKey: UserStreak.CodingKeys.lastWorkoutDate)
        try container.encode(self.createdAt, forKey: UserStreak.CodingKeys.createdAt)
        try container.encode(self.updatedAt, forKey: UserStreak.CodingKeys.updatedAt)
    }
}
