//
//  LogWorkoutView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI

struct LogWorkoutView: View {
    @State var selectedDuration: Int = 20
    let durationOptions: [Int] = [20, 25, 30, 35, 40, 45, 50, 55, 60]
    var body: some View {
        VStack(spacing: 24) {
            Text("How many minutes did you workout today?")
                .font(.system(size: 24, weight: .semibold))
                .multilineTextAlignment(.center)
            Picker("Picker", selection: $selectedDuration) {
                ForEach(durationOptions, id: \.self) { duration in
                    Text("\(duration) min").tag(duration)
                }
            }
            .pickerStyle(.menu)
            .tint(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 2))
            Text("Note: One workout can be logged each day.")
                .font(.system(size: 12, weight: .regular))
            Button(action: {
               
            }) {
                Text("Submit Workout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .padding(.horizontal, 16)
                    .background(Color.accentColor)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
            }
        }
        .foregroundStyle(Color.white)
        .padding(.horizontal, 48)
        .frame(maxWidth: .infinity)
        .background(
            Image("LogWorkoutBG")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    LogWorkoutView()
}
