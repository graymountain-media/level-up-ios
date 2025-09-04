//
//  FactionViewModel.swift
//  Level Up
//
//  Created by Sam Smith on 9/3/25.
//
import Foundation
import Combine
import Supabase
import FactoryKit

@MainActor
@Observable
class FactionHomeViewModel {
    @ObservationIgnored @Injected(\.factionHomeService) var factionHomeService
    @ObservationIgnored @Injected(\.appState) var appState
    // State properties
    var isLoading = true
    var errorMessage: String?
    var showError = false
    var selectedTab: FactionTabs = .overview
    var factionDetails: FactionDetails? = nil
    
    func fetchFactionDetails() async {
        isLoading = true
        showError = false
        errorMessage = nil
        
        let result = await factionHomeService.fetchFactionDetails()
        switch result {
        case .success(let factionDetails):
            self.factionDetails = factionDetails
            isLoading = false
        case .failure(let error):
            setError(error.localizedDescription)
        }
    }
    
    
    // MARK: - Private Methods
    
    /// Sets an error message and shows the error alert
    /// - Parameter message: Error message to display
    private func setError(_ message: String) {
        Task { @MainActor in
            isLoading = false
            errorMessage = message
            showError = true
        }
    }
}
