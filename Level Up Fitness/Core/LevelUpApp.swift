//
//  LevelUpApp.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI

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
                MainView()
                    .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.default, value: appState.isSignedIn)
    }
}
