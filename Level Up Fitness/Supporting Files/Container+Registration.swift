//
//  Container+Registrations.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/19/25.
//

import SwiftUI
import FactoryKit

extension Container {
    var appState: Factory<AppState> {
        self { @MainActor in AppState() }.singleton
    }
    
    var missionService: Factory<MissionServiceProtocol> {
        self { @MainActor in
            let appState = self.appState()
            return MissionService(client: appState.supabaseClient)
        }
    }
    
    var userDataService: Factory<UserDataServiceProtocol> {
        self { @MainActor in 
            let appState = self.appState()
            return UserDataService(client: appState.supabaseClient)
        }
    }
    
    var workoutService: Factory<WorkoutServiceProtocol> {
        self { @MainActor in WorkoutService(appState: self.appState()) }
    }
    
    var leaderboardService: Factory<LeaderboardServiceProtocol> {
        self { @MainActor in LeaderboardService(appState: self.appState()) }
    }
    
    var avatarService: Factory<AvatarServiceProtocol> {
        self { @MainActor in AvatarService(appState: self.appState()) }
    }
}

extension Container {
    func setupMocks() -> EmptyView {
        userDataService.register { @MainActor in MockUserDataService() }
        workoutService.register { @MainActor in MockWorkoutService() }
        leaderboardService.register { @MainActor in MockLeaderboardService() }
        avatarService.register { @MainActor in MockAvatarService() }
        missionService.register { @MainActor in MockMissionService() }
        return EmptyView()
    }
}
