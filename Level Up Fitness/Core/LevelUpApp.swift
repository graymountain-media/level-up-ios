//
//  LevelUpApp.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI

@Observable
class AppState {
    var isSignedIn = false
}
@main
struct LevelUpApp: App {
    @State var appState = AppState()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
        }
    }
}

struct RootView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        Group {
            if appState.isSignedIn {
                MainTabView()
                    .transition(.opacity)
            } else {
                SplashScreen()
                    .transition(.opacity)
            }
        }
        .animation(.default, value: appState.isSignedIn)
    }
}
