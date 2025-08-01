//
//  Navbar.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/31/25.
//

import SwiftUI
import FactoryKit

enum MainTab: Int, CaseIterable, Identifiable {
    case home
    case logWorkout
    case missionBoard
    case leaderboard
    
    var id: Int {
        return self.rawValue
    }
    
    var imageName: String {
        switch self {
        case .home:
            "avatar_icon"
        case .missionBoard:
            "missions_icon"
        case .logWorkout:
            "workout_icon"
        case .leaderboard:
            "leaderboard_icon"
        }
    }
    
    var title: String {
        switch self {
        case .home:
            "Home"
        case .missionBoard:
            "Missions"
        case .logWorkout:
            "Log a Workout"
        case .leaderboard:
            "Leaderboard"
        }
    }
}

struct LUTabBar: View {
    @InjectedObservable(\.appState) var appState
    var didSelectTab: (MainTab) -> Void
    
    var body: some View {
        HStack {
            ForEach(MainTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            Color.major.ignoresSafeArea()
        )
    }
    
    func tabButton(for tab: MainTab) -> some View {
        Button {
            didSelectTab(tab)
        } label: {
            VStack(alignment: .center, spacing: 4) {
                Image(tab.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text(tab.title)
                    .foregroundStyle(.textDetail)
                    .font(.system(size: 12))
            }
        }
    }
}

#Preview {
    LUTabBar { tab in
        
    }
}
