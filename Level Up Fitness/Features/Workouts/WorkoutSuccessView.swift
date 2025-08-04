//
//  WorkoutSuccessView.swift
//  Level Up
//
//  Created by Jake Gray on 8/4/25.
//

import SwiftUI
import FactoryKit

struct WorkoutSuccessView: View {
    var workout: Workout
    var dismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Check mark icon
            VStack(spacing: 12) {
                Image("checkmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                
                // Success title
                Text("WORKOUT LOGGED!")
                    .font(.mainFont(size: 28).bold())
                    .foregroundColor(.title)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ProgressBar()
            
            VStack(spacing: 12) {
                Text("+\(workout.xpEarned) XP EARNED")
                    .font(.mainFont(size: 30).bold())
                    .foregroundStyle(.textOrange)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Keep training to unlock new gear and evolve your avatar.")
                    .font(.system(size: 16))
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("View Missions to see what new missions are available to you.")
                    .font(.system(size: 16))
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(.textDetail)
            .multilineTextAlignment(.center)
            .padding(.bottom)
            
            
            // Continue button
            LUButton(title: "Continue") {
                dismiss()
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.minor.opacity(0.5), lineWidth: 2)
                .shadow(radius: 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.major)
                .shadow(radius: 20)
        )
        .padding(.horizontal, 24)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let _ = Container.shared.setupMocks()
    let workout = Workout(id: "1", userId: "1", duration: 20, workoutTypes: ["cardio"], date: Date(), xpEarned: 20)
    WorkoutSuccessView(workout: workout) {
        
    }
}
