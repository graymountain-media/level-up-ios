//
//  MainView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI
import FactoryKit

struct MainView: View {
    @InjectedObservable(\.appState) var appState
    @State var currentTab: MainTab = .home
    
    var body: some View {
        @Bindable var appState = appState
        ZStack {
            VStack(spacing: 0) {
                navbar
                currentTabView
                    .frame(maxHeight: .infinity)
                Spacer(minLength: 0)
                LUTabBar { tab in
                    currentTab = tab
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        appState.isShowingMenu.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .bold()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "bell.fill")
                    }
                }
            }
            .toolbarBackground(Color.major, for: .navigationBar)
            .tint(Color.minor)
            MainMenu()
        }
        .task {
            // Load user data when main view appears and user is authenticated
            if appState.isAuthenticated && appState.userAccountData == nil {
                await appState.loadUserData()
            }
        }
    }
    
    var navbar: some View {
        ZStack {
            HStack {
                Button {
                    appState.isShowingMenu.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                }
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "bell.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                }
            }
            .frame(height: 70)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(Color.major.ignoresSafeArea())
            HStack {
                Spacer()
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Spacer()
            }
            .frame(height: 70)
            .padding(.vertical, 8)

        }
    }
    @ViewBuilder
    var currentTabView: some View {
        switch currentTab {
        case .home:
            AvatarView()
        case .missionBoard:
            MissionBoardView()
        case .logWorkout:
            LogWorkoutView()
        case .leaderboard:
            LeaderboardView()
        }
    }
    
}

#Preview {
    MainView()
        .environment(AppState())
}
