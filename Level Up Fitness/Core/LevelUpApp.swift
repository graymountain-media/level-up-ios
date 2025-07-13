//
//  LevelUpApp.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI
import Supabase
import UIKit

@main
struct LevelUpApp: App {
    @State var appState = AppState()
    init() {
        for family: String in UIFont.familyNames {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family) {
                print("== \(names)")
            }
        }
    }
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
            if appState.supabaseService.isLoadingSession {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.major)
                    .transition(.opacity)
            }
            else if appState.isAuthenticated {
                MainView()
                    .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .onOpenURL { url in
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let items = urlComponents?.queryItems
        }
        .animation(.default, value: appState.isAuthenticated)
    }
}
