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
    
    
}
