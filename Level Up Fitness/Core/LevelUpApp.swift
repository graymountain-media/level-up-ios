//
//  LevelUpApp.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI
import Supabase
import FactoryKit

@main
struct LevelUpApp: App {
    @InjectedObservable(\.appState) var appState
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @InjectedObservable(\.appState) var appState
    @State private var showEmailConfirmedAlert = false
    @State private var showEmailErrorAlert = false
    @State private var emailErrorMessage = ""
    @State private var showResetPassword = false
    @State private var resetPasswordTokens: (accessToken: String, refreshToken: String)? = nil
    
    var body: some View {
        Group {
            if showResetPassword {
                // Show ResetPasswordView (currently just a text placeholder)
                PasswordResetView()
            } else {
                switch appState.authState {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.major)
                        .transition(.opacity)
                case .authenticated(let hasCompletedOnboarding):
                    if hasCompletedOnboarding {
                        MainView()
                            .transition(.opacity)
                    } else {
                        OnboardingView()
                            .transition(.opacity)
                    }
                case .unauthenticated:
                    GetStartedView()
                        .transition(.opacity)
                case .error(let error):
                    VStack {
                        Text("Authentication Error")
                            .font(.title)
                            .foregroundColor(.red)
                        Text(error.localizedDescription)
                            .foregroundColor(.secondary)
                        Button("Try Again") {
                            Task {
                                await appState.loadUserData()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.major)
                    .transition(.opacity)
                }
            }
        }
        .onOpenURL { url in
            guard url.scheme == "level-up-fitness" else {
                return
            }
            switch url.host {
            case "reset-password":
                // Parse fragment for access_token and refresh_token
                let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
                if let queryItems = urlComponents?.queryItems, let code = queryItems.first(where: { $0.name == "code" })?.value {
                    Task {
                        do {
                            try await appState.supabaseClient.auth.session(from: url)
                            showResetPassword = true
                        } catch {
                            emailErrorMessage = "Failed to set session: \(error.localizedDescription)"
                            showEmailErrorAlert = true
                        }
                        return
                    }
                } else {
                    
                }
                return
                
            case "login-callback":
                let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
                if let errorCode = urlComponents?.queryItems?.first(where: { $0.name == "error_code" })?.value,
                   let errorDescription = urlComponents?.queryItems?.first(where: { $0.name == "error_description" })?.value {
                    let formattedDescription = errorDescription.replacingOccurrences(of: "+", with: " ")
                    emailErrorMessage = "Error: \(formattedDescription) (\(errorCode))"
                    showEmailErrorAlert = true
                } else if let fragment = url.fragment,
                          fragment.contains("error_code") {
                    let fragmentComponents = fragment.components(separatedBy: "&")
                    var errorCode = ""
                    var errorDescription = ""
                    for component in fragmentComponents {
                        let keyValue = component.components(separatedBy: "=")
                        if keyValue.count == 2 {
                            if keyValue[0] == "error_code" {
                                errorCode = keyValue[1]
                            } else if keyValue[0] == "error_description" {
                                errorDescription = keyValue[1].replacingOccurrences(of: "+", with: " ")
                            }
                        }
                    }
                    if !errorCode.isEmpty {
                        emailErrorMessage = "Error: \(errorDescription) (\(errorCode))"
                        showEmailErrorAlert = true
                    }
                } else {
                    showEmailConfirmedAlert = true
                }
            default: return
            }
        }
        .alert("Email Confirmed", isPresented: $showEmailConfirmedAlert) {
            Button("OK") {
                // Alert dismissed
            }
        } message: {
            Text("Your email has been confirmed. You can now sign in to your account.")
        }
        .alert("Email Confirmation Failed", isPresented: $showEmailErrorAlert) {
            Button("OK") {
                // Alert dismissed
            }
        } message: {
            Text(emailErrorMessage)
        }
        .animation(.default, value: appState.isAuthenticated)
    }
}
