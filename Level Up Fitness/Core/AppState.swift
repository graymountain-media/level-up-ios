//
//  AppState.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI
import Combine

@Observable
@MainActor
class AppState {
    // Navigation state
    var isShowingMenu: Bool = false
    var presentedDestination: Destination?
    
    // Workout state
    var workout: DailyWorkout?
    
    // Supabase service reference
    let supabaseService = SupabaseService()
    
    var isAuthenticated: Bool {
        return supabaseService.isAuthenticated
    }
}
