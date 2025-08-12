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
    
    var requiredContent: UnlockableContent? {
        switch self {
        case .home, .logWorkout, .leaderboard:
            return nil // Always available
        case .missionBoard:
            return .missions
        }
    }
}

struct LUTabBar: View {
    @InjectedObservable(\.appState) var appState
    var tipsNamespace: Namespace.ID
    var tipManager: SequentialTipsManager
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
        var isUnlocked: Bool = true
        if let content = tab.requiredContent {
            isUnlocked = appState.isContentUnlocked(content)
        }
        let button = Button {
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
            .opacity(isUnlocked ? 1 : 0.5)
        }
            .disabled(!isUnlocked)
        
        return Group {
            if tab == .missionBoard {
                button
                .tipSource(id: 99, nameSpace: tipsNamespace, manager: tipManager, anchorPoint: .top)
            } else if tab == .logWorkout {
                button
                .tipSource(id: 5, nameSpace: tipsNamespace, manager: tipManager, anchorPoint: .top)
            } else {
                button
            }
        }
    }
}


//#Preview {
//    LUTabBar { tab in
//        
//    }
//}
