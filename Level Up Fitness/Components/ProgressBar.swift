//
//  ProgressBar.swift
//  Level Up
//
//  Created by Jake Gray on 8/4/25.
//

import SwiftUI
import FactoryKit

struct ProgressBar: View {
    @InjectedObservable(\.appState) var appState
    
    var progress: Double {
        let progress = appState.userAccountData?.progressToNextLevel ?? 0.0
        if progress > 0 {
            return progress
        } else {
            return 0
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Text("Level \(appState.userAccountData?.currentLevel ?? 1)")
                    .font(.system(size: 25, weight: .medium))
                Spacer()
                Text("\(appState.userAccountData?.xpToNextLevel ?? 100) XP to next level")
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 12)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .foregroundColor(Color.textfieldBg)
                    
                    // Progress fill with gradient
                    Capsule()
                        .frame(width: geometry.size.width * progress)
                        .foregroundStyle(LinearGradient(
                            colors: [Color(red: 0.3, green: 0.8, blue: 0.3), Color.green],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                }
            }
            .frame(height: 24)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .foregroundStyle(.white)
    }
}

#Preview {
    ProgressBar()
}
