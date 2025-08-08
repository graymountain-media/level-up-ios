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
        self { @MainActor in AppState() }.cached
    }
    
    var missionManager: Factory<MissionManager> {
        self {
            @MainActor in MissionManager()
        }.cached
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
    
    var levelManager: Factory<LevelManager> {
        self { @MainActor in LevelManager() }.singleton
    }
    
    var pathCalculator: Factory<PathCalculator> {
        self { @MainActor in PathCalculator() }
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
