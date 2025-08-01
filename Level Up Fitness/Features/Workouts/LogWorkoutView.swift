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
    
    @State private var selectedDuration: Int = 20
    @State private var selectedWorkoutTypes: [WorkoutType] = []
    
    @State private var todaysWorkout: Workout? = nil
    @State private var currentStreak: Int = 0
    
    @State private var showHelp: Bool = false
    let durationOptions: [Int] = [20, 25, 30, 35, 40, 45, 50, 55, 60]
    
    var hasWorkoutForToday: Bool {
        return todaysWorkout != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            FeatureHeader(title: "Log A Workout")
            ScrollView {
                if viewModel.isLoading {
                    loadingView
                } else if hasWorkoutForToday {
                    workoutSuccessView
                } else {
                    workoutFormView
                }
                Spacer()
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity)
        .background(
            Image("main_bg")
                .resizable()
                .ignoresSafeArea()
        )
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { viewModel.showError = false }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .task {
            // Load today's workout when view appears
            await loadTodaysWorkout()
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
    
    var workoutSuccessView: some View {
        VStack(spacing: 36) {
            // Check mark icon
            VStack(spacing: 6) {
                Image("checkmark")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100)
                
                // Success title
                Text("WORKOUT\nLOGGED!")
                    .font(.mainFont(size: 40).bold())
                    .foregroundColor(.title)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            
            // Level progress section
            VStack(spacing: 8) {
                HStack {
                    Text("LEVEL \(appState.userAccountData?.currentLevel ?? 1)")
                        .font(.mainFont(size: 24).bold())
                        .foregroundColor(.textOrange)
                    
                    Spacer()
                    
                    Text("\(appState.userAccountData?.xpToNextLevel ?? 100) to next level")
                        .font(.system(size: 14))
                        .foregroundColor(.textDetail)
                }
                .padding(.horizontal)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 20)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.green)
                            .frame(width: geometry.size.width * (appState.userAccountData?.progressToNextLevel ?? 0.0), height: 20)
                    }
                }
                .frame(height: 20)
            }
            
            // XP earned
            Text("+\(todaysWorkout?.xpEarned ?? 40) XP EARNED")
                .font(.mainFont(size: 30).bold())
                .foregroundColor(.textOrange)
            
            // Motivational text
            VStack(spacing: 16) {
                Text("Keep training to unlock new gear and evolve your avatar.")
                    .font(.system(size: 16))
                    .italic()
                    .foregroundColor(.textDetail)
                    .multilineTextAlignment(.center)
                
                Text("View Missions to see what new missions are available to you.")
                    .font(.system(size: 16))
                    .italic()
                    .foregroundColor(.textDetail)
                    .multilineTextAlignment(.center)
            }
            
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 30)
    }
    
    var workoutFormView: some View {
        VStack(spacing: 24) {
            durationSelector
            typeSection
            LUButton(title: "Log Workout", isLoading: viewModel.isLoading) {
                Task {
                    await saveWorkout()
                }
            }
            helpSection
        }
        .padding(.horizontal, 50)
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity)
    }
    
    var durationSelector: some View {
        VStack(alignment: .leading) {
            Text("Duration")
                .font(.system(size: 14))
                .foregroundStyle(Color.textDetail)
            HStack {
                Menu {
                    ForEach(durationOptions, id: \.self) { duration in
                        Button {
                            selectedDuration = duration
                        } label: {
                            Text("\(duration) Mins")
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.textInput)
                                .tag(duration)
                        }
                    }
                } label: {
                    HStack {
                        Text("\(selectedDuration) Mins")
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
                print("Tapped")
                showHelp = true
            } label: {
                Text("User Guidelines")
                    .font(.mainFont(size: 16))
                    .bold()
                    .foregroundStyle(.title)
            }
            .popover(isPresented: $showHelp, attachmentAnchor: .point(.top), arrowEdge: .none) {
                VStack {
                    Text("Title")
                        .font(.headline)
                        .foregroundStyle(.title)
                    Text("Explanation for what this tool tip is for")
                        .font(.subheadline)
                        .foregroundStyle(.minor)
                }
                .padding(.horizontal)
                .presentationCompactAdaptation(.popover)
            }
            
        }
    }
    
    // Function to save or update a workout
    private func saveWorkout() async {
        guard !selectedWorkoutTypes.isEmpty else {
            viewModel.errorMessage = "Please select at least one workout type"
            viewModel.showError = true
            return
        }
        
        await viewModel.saveWorkout(
            duration: selectedDuration,
            types: selectedWorkoutTypes.map { $0.rawValue }
        )
        
        if viewModel.saveSuccess {
            // Refresh the workout data
            await loadTodaysWorkout()
            
            // Update centralized user data with new XP
            if let workout = todaysWorkout {
                await appState.updateUserXP(additionalXP: workout.xpEarned)
            }
        }
    }
    
    // Load today's workout if it exists
    private func loadTodaysWorkout() async {
        todaysWorkout = await viewModel.fetchTodaysWorkout()
    }
}

#Preview {
    let _ = Container.shared.setupMocks()
    LogWorkoutView()
}
