//
//  LogWorkoutView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI
import FactoryKit
import TipKit

enum WorkoutIntensity: String, CaseIterable {
    case low
    case medium
    case high
}

enum WorkoutType: String, CaseIterable {
    case cardio
    case strength
    case functional
}

struct LogWorkoutView: View {
    @InjectedObservable(\.appState) var appState
    @State private var viewModel = WorkoutViewModel()
    
    @State private var selectedDuration: Int?
    @State private var selectedWorkoutTypes: [WorkoutType] = []
    
    @State private var todaysWorkouts: [Workout] = []
    @State private var currentStreak: Int = 0
    @State private var availableMinutes: Int = 60
    @State private var totalMinutesToday: Int = 0
    @State private var showWorkoutSuccess: Bool = false
    @State private var latestLoggedWorkout: Workout?
    @State var tipManager = SequentialTipsManager.workoutTips()
    @Namespace var namespace
    @State private var showHelp: Bool = false
    let durationOptions: [Int] = [20, 25, 30, 35, 40, 45, 50, 55, 60]
    
    var hasMaxedOutToday: Bool {
        return availableMinutes <= 0
    }
    
    var canLogSelectedWorkout: Bool {
        guard let selectedDuration, !selectedWorkoutTypes.isEmpty else { return false }
        return selectedDuration <= availableMinutes
    }
    
    var body: some View {
        VStack(spacing: 0) {
            FeatureHeader(title: "Log A Workout")
            ScrollView {
                if viewModel.isLoading {
                    loadingView
                } else {
                    workoutFormView
                }
                Spacer()
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity)
        .mainBackground()
        .messageOverlay(namespace: namespace, manager: tipManager)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { viewModel.showError = false }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .task {
            // Load today's workouts and calculate available minutes
            await loadTodaysData()
        }
        .fullScreenCover(item: $latestLoggedWorkout) { workout in
            WorkoutSuccessView(workout: workout, dismiss: {
                dismissWorkoutSuccess()
            })
            .presentationBackground(.clear)
        }
    }
    
    var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.5)
            
            Text("Loading workout data...")
                .font(.system(size: 16))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 100)
    }
    
    
    
    var workoutFormView: some View {
        VStack(spacing: 24) {
            durationSelector
            typeSection
            VStack(spacing: 12) {
                availableMinutesView
                LUButton(title: "Log Workout", isLoading: viewModel.isLoading) {
                    Task {
                        await saveWorkout()
                    }
                }
                .disabled(!canLogSelectedWorkout)
                helpSection
            }
        }
        .onAppear {
            tipManager.showSingleTip(key: "workout_welcome")
        }
        .padding(.horizontal, 50)
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity)
    }
    
    var availableMinutesView: some View {
        let willLogTooMuch: Bool = selectedDuration ?? 0 > availableMinutes
        return VStack(spacing: 4) {
            if availableMinutes > 0 {
                Text("\(willLogTooMuch ? "You only have " : "")\(availableMinutes) minutes available to log today")
                    .font(.system(size: 14))
                    .foregroundColor(willLogTooMuch ? .red : .textDetail)
                    .multilineTextAlignment(.center)
            } else {
                Text("Max minutes reached. Log your next workout tomorrow")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }
    var durationSelector: some View {
        var durationText: String {
            guard let selectedDuration else {
                return "Select duration"
            }
            return "\(selectedDuration) Mins"
        }
        return VStack(alignment: .leading) {
            Text("Duration")
                .font(.system(size: 14))
                .foregroundStyle(Color.textDetail)
            HStack {
                Menu {
                    ForEach(durationOptions, id: \.self) { duration in
                        Button {
                            selectedDuration = duration
                        } label: {
                            Text("\(duration) mins")
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.textInput)
                                .tag(duration)
                        }
                    }
                } label: {
                    HStack {
                        Text(durationText)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textInput)
                        Spacer()
                        
                    }
                    .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 38)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.textfieldBg)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.textfieldBorder)
            }
        }
    }
    
    var typeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout Type (select all that apply)")
                .font(.system(size: 14))
                .foregroundStyle(Color.textDetail)
            ForEach(WorkoutType.allCases, id: \.rawValue) { type in
                typeButton(for: type)
            }
        }
    }
    
    private func typeButton(for type: WorkoutType) -> some View {
        let isSelected = selectedWorkoutTypes.contains(type)
        return Button {
            if isSelected {
                selectedWorkoutTypes.removeAll(where: { $0 == type })
            } else {
                selectedWorkoutTypes.append(type)
            }
        } label: {
            Text(type.rawValue.uppercased())
                .font(.system(size: 14))
                .foregroundStyle(Color.textInput)
                .frame(maxWidth: .infinity)
        }
        .padding(8)
        .frame(height: 38)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.minor.opacity(0.5))
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.textfieldBg)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.textfieldBorder)
        }
    }
    
    var helpSection: some View {
        VStack(alignment: .center, spacing: 4) {
            Text("Questions?")
                .font(.system(size: 14))
                .foregroundStyle(Color.textDetail)
            Button {
                tipManager.forceShowTip(key: "workout_guidelines")
            } label: {
                Text("User Guidelines")
                    .font(.mainFont(size: 16))
                    .bold()
                    .foregroundStyle(.title)
            }
            .messageSource(id: 1, nameSpace: namespace)
            
        }
    }
    
    // Function to save or update a workout
    private func saveWorkout() async {
        guard let selectedDuration else {
            viewModel.errorMessage = "Please enter a workout duration"
            viewModel.showError = true
            return
        }
        guard !selectedWorkoutTypes.isEmpty else {
            viewModel.errorMessage = "Please select at least one workout type"
            viewModel.showError = true
            return
        }
        
        // Check if the selected duration would exceed daily limit
        guard await viewModel.canLogWorkout(duration: selectedDuration) else {
            viewModel.errorMessage = "This workout would exceed your daily 60-minute limit. You have \(availableMinutes) minutes remaining."
            viewModel.showError = true
            return
        }
        
        let workout = await viewModel.saveWorkout(
            duration: selectedDuration,
            types: selectedWorkoutTypes.map { $0.rawValue }
        )
        
        if let workout {
            await appState.updateUserXP(additionalXP: workout.xpEarned)
            // Show success popup
            withAnimation {
                latestLoggedWorkout = workout
            }
            // Refresh the workout data
            await loadTodaysData()
            
            self.selectedDuration = nil
            selectedWorkoutTypes = []
        }
    }
    
    // Load today's workouts and calculate available minutes
    private func loadTodaysData() async {
        viewModel.isLoading = true
        todaysWorkouts = await viewModel.fetchTodaysWorkouts()
        totalMinutesToday = await viewModel.fetchTodaysTotalMinutes()
        availableMinutes = await viewModel.fetchAvailableMinutes()
        viewModel.isLoading = false
    }
    
    // Dismiss workout success popup
    private func dismissWorkoutSuccess() {
        withAnimation {
            latestLoggedWorkout = nil
        }
        // Notify AppState that workout success is dismissed
        appState.showLevelPopupIfNeeded()
    }
}

#Preview {
    let _ = Container.shared.setupMocks()
    LogWorkoutView()
}
