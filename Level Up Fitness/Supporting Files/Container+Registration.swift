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
    
    var missionManager: Factory<MissionManager> {
        self {
            @MainActor in MissionManager()
        }.singleton
    }
    
    var missionService: Factory<MissionServiceProtocol> {
        self { @MainActor in
            return MissionService()
        }
    }
    
    var userDataService: Factory<UserDataServiceProtocol> {
        self { @MainActor in
            return UserDataService()
        }
    }
    
    var workoutService: Factory<WorkoutServiceProtocol> {
        self { @MainActor in WorkoutService() }
    }
    
    var leaderboardService: Factory<LeaderboardServiceProtocol> {
        self { @MainActor in LeaderboardService() }
    }
    
    var avatarService: Factory<AvatarServiceProtocol> {
        self { @MainActor in AvatarService() }
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
