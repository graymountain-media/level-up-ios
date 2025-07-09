//
//  MainView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI

enum Destination: Int, CaseIterable, Identifiable {
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
    @Environment(AppState.self) var appState
    
    var body: some View {
        @Bindable var appState = appState
        ZStack {
            NavigationStack {
                ZStack(alignment: .leading) {
                    // Side Menu
                    VStack(spacing: 0) {
                        avatarView
                        navBar
                    }
                }
            }
            .tint(Color.minor)
            SlideOutMenu()
        }
        .fullScreenCover(item: $appState.presentedDestination) { destination in
            switch destination {
            case .avatar:
                EmptyView()
            case .inventory:
                InventoryView()
            case .itemShop:
                ItemShopView()
            case .missionBoard:
                MissionBoardView()
            case .logWorkout:
                LogWorkoutView()
            case .leaderboard:
                LeaderboardView()
            }
        }
    }
    
    var avatarView: some View {
        AvatarView()
            .background(Color.major.edgesIgnoringSafeArea(.all))
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
            .toolbarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbarBackground(Color.major, for: .navigationBar)
    }
    
    var navBar: some View {
        HStack {
            Button {
                appState.presentedDestination = .missionBoard
            } label: {
                Image(Destination.missionBoard.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
            }
            Button {
                appState.presentedDestination = .logWorkout
            } label: {
                Image(Destination.logWorkout.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
            }
            Button {
                appState.presentedDestination = .itemShop
            } label: {
                Image(Destination.itemShop.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            Color.major.ignoresSafeArea()
        )
    }
    
}

#Preview {
    MainView()
        .environment(AppState())
}
