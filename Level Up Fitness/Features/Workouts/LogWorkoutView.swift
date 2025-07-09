//
//  LogWorkoutView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI

struct DailyWorkout: Identifiable {
    let id = UUID()
    var duration: Int
    var type: String
    var date: Date
}

struct LogWorkoutView: View {
    @Environment(AppState.self) var appState
    @State private var selectedDuration: Int = 20
    @State private var selectedWorkoutType: String = "Cardio"
    @State private var isEditingWorkout: Bool = false
    @State private var todaysWorkout: DailyWorkout? = nil
    
    let durationOptions: [Int] = [20, 25, 30, 35, 40, 45, 50, 55, 60]
    let workoutTypes = ["Cardio", "Strength", "Flexibility"]
    
    var hasWorkoutForToday: Bool {
        return appState.workout != nil
    }
    
    var body: some View {
        @Bindable var appState = appState
        VStack(spacing: 24) {
            FeatureHeader(titleImageName: "workout_title")
            Spacer()
            
            if hasWorkoutForToday && !isEditingWorkout {
                workoutAlreadyLoggedView
            } else {
                workoutFormView
            }
            
            Spacer()
            Spacer()
        }
        .onAppear {
            if let workout = appState.workout {
                self.selectedDuration = workout.duration
                self.selectedWorkoutType = workout.type
            }
        }
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity)
        .background(
            Color.major.ignoresSafeArea()
        )
    }
    
    var durationSelector: some View {
        VStack(alignment: .leading) {
            Text("Duration")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.textOrange)
            Picker("Picker", selection: $selectedDuration) {
                ForEach(durationOptions, id: \.self) { duration in
                    Text("\(duration) min")
                        .frame(maxWidth: .infinity)
                        .tag(duration)
                }
            }
            .frame(maxWidth: .infinity)
            .pickerStyle(.menu)
            .tint(Color.white)
            .overlay {
                CustomBorderShape()
                    .stroke(Color.border)
            }
        }
    }
    
    var typeSelector: some View {
        VStack(alignment: .leading) {
            Text("Workout Type")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.textOrange)
            Picker("Picker", selection: $selectedWorkoutType) {
                ForEach(workoutTypes, id: \.self) { type in
                    Text(type)
                        .frame(maxWidth: .infinity)
                        .tag(type)
                }
            }
            .frame(maxWidth: .infinity)
            .pickerStyle(.menu)
            .tint(Color.white)
            .overlay {
                CustomBorderShape()
                    .stroke(Color.border)
            }
        }
    }


    // View shown when a workout has already been logged for today
    var workoutAlreadyLoggedView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Workout Already Logged")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 8) {
                    if let workout = todaysWorkout {
                        HStack {
                            Text("Type:")
                                .fontWeight(.semibold)
                            Text(workout.type)
                        }
                        
                        HStack {
                            Text("Duration:")
                                .fontWeight(.semibold)
                            Text("\(workout.duration) minutes")
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.major.opacity(0.3))
                )
                
                Text("You've already logged a workout for today. Great job staying active!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    isEditingWorkout = true
                }) {
                    Text("Edit Today's Workout".uppercased())
                        .font(.headline)
                        .foregroundColor(.textOrange)
                        .padding()
                        .padding(.horizontal, 16)
                        .overlay {
                            CustomBorderShape(cornerWidth: 13)
                                .stroke(Color.border)
                            CustomBorderShape()
                                .stroke(Color.textOrange)
                                .padding(4)
                        }
                }
            }
            .padding(.horizontal, 48)
        }
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity)
        .background(
            Color.major.ignoresSafeArea()
        )
    }
    
    // View for entering a new workout or editing an existing one
    var workoutFormView: some View {
        VStack(spacing: 24) {
            durationSelector
            typeSelector
            Text("Note: One workout can be logged each day.")
                .font(.system(size: 12, weight: .regular))
            Button(action: {
                saveWorkout()
            }) {
                Text(isEditingWorkout ? "Update Workout".uppercased() : "Submit Workout".uppercased())
                    .font(.headline)
                    .foregroundColor(.textOrange)
                    .padding()
                    .padding(.horizontal, 16)
                    .overlay {
                        CustomBorderShape(cornerWidth: 13)
                            .stroke(Color.border)
                        CustomBorderShape()
                            .stroke(Color.textOrange)
                            .padding(4)
                    }
            }
            
            if isEditingWorkout {
                Button(action: {
                    isEditingWorkout = false
                }) {
                    Text("Cancel")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 8)
                }
            }
        }
        .padding(.horizontal, 48)
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity)
        .background(
            Color.major.ignoresSafeArea()
        )
    }
    
    // Function to save or update a workout
    private func saveWorkout() {
        let workout = DailyWorkout(
            duration: selectedDuration,
            type: selectedWorkoutType,
            date: Date()
        )
        
        // Here you would save the workout to your data store
        appState.workout = workout
        
        // In a real app, you'd persist this data
    }
}

#Preview {
    LogWorkoutView()
}
