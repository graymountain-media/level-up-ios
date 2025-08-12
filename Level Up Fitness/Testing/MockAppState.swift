//
//  MockAppState.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/12/25.
//

import SwiftUI
import FactoryKit

@Observable
@MainActor
class MockAppState: AppState {
    
    override init() {
        super.init()
        
        // Set authenticated state immediately
        self.authState = .authenticated(hasCompletedOnboarding: true)
        self.isLoadingUserData = false
        
        // Pre-populate with mock user data
        Task {
            await loadUserData()
        }
    }
    
    override func refreshUserData() async {
        // Do nothing - data is already set
    }
    
    override func refreshUserInventory() async {
        // Do nothing - inventory is already set
    }
    
    override func updateUserXP(additionalXP: Int) async {
        // Simulate XP update without network call
    }
}
