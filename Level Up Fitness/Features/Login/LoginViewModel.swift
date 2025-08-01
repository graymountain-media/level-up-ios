//
//  LoginViewModel.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/16/25.
//

import Foundation
import FactoryKit

@Observable
class LoginViewModel {
    @ObservationIgnored @Injected(\.appState) var appState
    var isLogin: Bool
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var showingResetPassword = false
    var showingAlert = false
    var alertMessage = ""
    var showConfirmEmailView: Bool = false
    var emailToConfirm: String = ""
    var isLoading: Bool = false
    var isShowingResetConfirmation = false
    
    
    init(isLogin: Bool) {
        self.isLogin = isLogin
    }
    
    var isPrimaryDisabled: Bool {
        if isLogin {
            return email.isEmpty || password.isEmpty
        } else {
            return email.isEmpty ||
            password.isEmpty ||
            confirmPassword.isEmpty
        }
    }
    
    func handleAuthentication() {
        func resetFields() {
            emailToConfirm = email
            email = ""
            password = ""
            confirmPassword = ""
            isLogin = true
        }
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all required fields"
            showingAlert = true
            return
        }
        
        
        
        if isLogin {
            isLoading = true
            Task {
                let result = await appState.signIn(email: email, password: password)
                switch result {
                case .success(let success):
                    return
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
                isLoading = false
            }
        } else {
            // Handle signup
            guard !email.isEmpty, !password.isEmpty else {
                alertMessage = "Please fill in all required fields"
                showingAlert = true
                return
            }
            
            guard password == confirmPassword else {
                alertMessage = "Passwords must match"
                showingAlert = true
                return
            }
            isLoading = true
            Task {
                let result = await appState.signUp(
                    email: email,
                    password: password
                )
                switch result {
                case .success:
                    showConfirmEmailView = true
                    resetFields()
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
                isLoading = false
            }
        }
    }
    
    func resetPassword() {
        isLoading = true
        Task {
            let result = try await appState.resetPassword(email: email)
            switch result {
            case .success:
                isShowingResetConfirmation = true
            case .failure(let error):
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            isLoading = false
        }
    }
}
