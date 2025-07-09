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