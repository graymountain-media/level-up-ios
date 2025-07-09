//
//  MainView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI

enum MainMenuItem: Int, CaseIterable, Identifiable {
    case avatar
    case inventory
    case itemShop
    case missionBoard
    case logWorkout
//    case activeMissions
    case leaderboard
    
    var id: Int {
        return self.rawValue
    }
    
    var imageName: String {
        switch self {
        case .avatar:
            "avatar_icon"
        case .inventory:
            "bag_icon"
        case .itemShop:
            "store_icon"
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
        case .avatar:
            "My Avatar"
        case .inventory:
            "Inventory"
        case .itemShop:
            "Item Shop"
        case .missionBoard:
            "Mission Board"
        case .logWorkout:
            "Log a Workout"
        case .leaderboard:
            "Leaderboards"
        }
    }
}

struct MainView: View {
    @State private var currentTab: Int = 0
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentTab) {
                AvatarView().tag(0)
                LogWorkoutView().tag(1)
                Text("Leaderboard").tag(2)
                Text("Account").tag(3)
                MissionBoardView().tag(4)
            }
            Rectangle()
                .fill(Color.white)
                .frame(height: 1)
            HStack(spacing: 0) {
                ForEach(MainTab.allCases) { tab in
                    tabItem(forTab: tab)
                }
            }
            .background(LinearGradient(colors: [.tabBarStart, .tabBarEnd], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea())
        }
    }
    
    func tabItem(forTab tab: MainTab) -> some View {
        let isSelected = currentTab == tab.rawValue
        return Button(action: {
            currentTab = tab.rawValue
        }, label: {
            VStack {
                Image(systemName: tab.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 24)
                Text(tab.title)
                    .font(.system(size: 10))
            }
            .foregroundStyle(isSelected ? Color.accent : Color.white)
        })
        .buttonStyle(.plain)
        .frame(height: 60)
        .padding(.horizontal, 2)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MainView()
}
