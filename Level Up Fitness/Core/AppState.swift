//
//  AppState.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI

@Observable
class AppState {
    var isSignedIn = false
    var isShowingMenu: Bool = false
    var presentedDestination: Destination?
    var workout: DailyWorkout?
}
