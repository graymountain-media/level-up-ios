//
//  MainTabView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI

enum MainTab: Int, CaseIterable, Identifiable {
    case avatar
    case logWorkout
    case leaderboard
    case account
    case missionBoard
    
    var id: Int {
        return self.rawValue
    }
    
    var imageName: String {
        switch self {
        case .avatar:
            return "person.2.circle"
        case .logWorkout:
            return "pencil"
        case .leaderboard:
            return "list.bullet.rectangle"
        case .account:
            return "person.crop.circle"
        case .missionBoard:
            return "star"
        }
    }
    
    var title: String {
        switch self {
        case .avatar:
            return "Avatar"
        case .logWorkout:
            return "Log Workout"
        case .leaderboard:
            return "Leaderboard"
        case .account:
            return "Account"
        case .missionBoard:
            return "Mission Board"
        }
    }
}

struct MainTabView: View {
    @State private var currentTab: Int = 0
    var body: some View {
        VStack {
            TabView(selection: $currentTab) {
                Text("Avatar").tag(0)
                Text("Log Workout").tag(1)
                Text("Leaderboard").tag(2)
                Text("Account").tag(3)
                Text("Mission Board").tag(4)
            }
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
    MainTabView()
}
