//
//  PasswordResetViewModel.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/9/25.
//

import Foundation
import FactoryKit

@Observable
class PasswordResetViewModel {
    @ObservationIgnored @Injected(\.appState) var appState
    
    var newPassword: String = ""
    var confirmPassword: String = ""
    var isLoading: Bool = false
    var showingAlert: Bool = false
    var alertMessage: String = ""
    var passwordResetSuccess: Bool = false
    
    var isContinueDisabled: Bool {
        return newPassword.isEmpty || 
               confirmPassword.isEmpty || 
               newPassword != confirmPassword ||
               newPassword.count < 6 ||
               isLoading
    }
    
    func updatePassword() {
        guard !newPassword.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "Please fill in all fields"
            showingAlert = true
            return
        }
        
        guard newPassword == confirmPassword else {
            alertMessage = "Passwords must match"
            showingAlert = true
            return
        }
        
        guard newPassword.count >= 6 else {
            alertMessage = "Password must be at least 6 characters"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            let result = await appState.updatePassword(newPassword: newPassword)
            
            await MainActor.run {
                isLoading = false
                
                switch result {
                case .success:
                    passwordResetSuccess = true
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
}