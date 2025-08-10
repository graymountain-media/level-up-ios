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
    @Namespace var mainViewNamespace
    let tipManager = SequentialTipsManager(tips: [], storageKey: "missions_unlocked_temp")
    
    init() {
        tipManager.registerSingleTip(
            key: "missions_unlocked",
            id: 99,
            title: "Missions Unlocked!",
            message: "You can now take on missions to earn bonus XP and exclusive rewards. Tap the Missions tab to get started!",
            position: .top
        )
    }
    
    var body: some View {
        @Bindable var appState = appState
        ZStack {
            VStack(spacing: 0) {
                navbar
                currentTabView
                    .frame(maxHeight: .infinity)
                Spacer(minLength: 0)
                LUTabBar { tab in
                    appState.currentTab = tab
                }
                .tipSource(id: 99, nameSpace: mainViewNamespace, manager: tipManager, anchorPoint: .top)
            }
            .tint(Color.minor)
            .fullScreenCover(item: $appState.selectedMenuItem) { item in
                switch item {
                case .accountSettings:
                    ProfileSettings()
                case .itemShop:
                    ItemShopView()
                case .help:
                    EmptyView()
                }
            }
            MainMenu()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showMissionsUnlockedTip)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                tipManager.showSingleTip(key: "missions_unlocked")
            }
        }
        .tipOverlay(namespace: mainViewNamespace, manager: tipManager)
        .overlay {
            if appState.isShowingHelp {
                HelpCenterView()
                    .transition(.opacity)
            }
        }
        .overlay {
            // Single Flow Overlay - observes appState.flowManager.currentFlow
            Group {
                switch appState.flowManager.currentFlow {
                case .levelUp(let notification):
                    LevelUpPopupView(notification: notification) {
                        appState.dismissLevelUpPopup()
                    }
                    .transition(.opacity)
                    
                case .pathAssignment(let path):
                    PathAssignmentOverlay(
                        assignedPath: path,
                        onDismiss: {
                            appState.dismissPathAssignment()
                        },
                        pathIconNamespace: mainViewNamespace
                    )
                    .transition(.opacity)
                    
                case .factionSelection:
                    FactionSelectionView(
                        onFactionSelected: { faction in
                            appState.selectFaction(faction)
                        },
                        onDismiss: {
                            appState.dismissFactionSelection()
                        }
                    )
                    .transition(.opacity)
                    
                case nil:
                    EmptyView()
                }
            }
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
        switch appState.currentTab {
        case .home:
            AvatarView(mainNamespace: mainViewNamespace)
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
