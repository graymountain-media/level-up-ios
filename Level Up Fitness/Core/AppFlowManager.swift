//
//  AppFlowManager.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/10/25.
//

import Foundation
import SwiftUI

/// Represents the different application flow states
@MainActor
enum AppFlow: Equatable {
    case levelUp(LevelUpNotification)
    case pathAssignment(HeroPath)
    case factionSelection
    
    /// Priority for flow ordering (higher number = higher priority)
    var priority: Int {
        switch self {
        case .levelUp: return 3  // Highest priority
        case .pathAssignment: return 2
        case .factionSelection: return 1  // Lowest priority
        }
    }
    
    nonisolated static func == (lhs: AppFlow, rhs: AppFlow) -> Bool {
        switch (lhs, rhs) {
        case (.levelUp(let lhsNotification), .levelUp(let rhsNotification)):
            return lhsNotification.toLevel == rhsNotification.toLevel
        case (.pathAssignment(let lhsPath), .pathAssignment(let rhsPath)):
            return lhsPath == rhsPath
        case (.factionSelection, .factionSelection):
            return true
        default:
            return false
        }
    }
}

/// Protocol for AppFlowManager dependency
@MainActor
protocol AppFlowManagerProtocol {
    var currentFlow: AppFlow? { get }
    
    func nextFlow()
    func queueFlow(_ flow: AppFlow)
    func reset()
}

/// Manages application flow state transitions
@MainActor
@Observable
class AppFlowManager: AppFlowManagerProtocol {
    private(set) var currentFlow: AppFlow?
    private var pendingTransitions: [AppFlow] = []
    
    // MARK: - Public Interface
    
    /// Queue a flow to be displayed, inserting it in priority order
    func queueFlow(_ flow: AppFlow) {
        print("📥 Queueing flow: \(flow)")
        
        // Remove any existing flow of the same type to avoid duplicates
        pendingTransitions.removeAll { existingFlow in
            switch (existingFlow, flow) {
            case (.levelUp, .levelUp), (.pathAssignment, .pathAssignment), (.factionSelection, .factionSelection):
                return true
            default:
                return false
            }
        }
        
        // Insert in priority order (highest priority first)
        if let insertIndex = pendingTransitions.firstIndex(where: { $0.priority < flow.priority }) {
            pendingTransitions.insert(flow, at: insertIndex)
        } else {
            pendingTransitions.append(flow)
        }
        
        print("📋 Pending transitions: \(pendingTransitions.count) flows queued")
        print("PENDING TRANSITIONS: \(pendingTransitions)")
    }
    
    /// Move to the next flow in the queue, or clear current flow if queue is empty
    func nextFlow() {
        if let nextFlow = pendingTransitions.first {
            pendingTransitions.removeFirst()
            withAnimation {
                currentFlow = nextFlow
            }
            print("▶️ Starting flow: \(nextFlow)")
        } else {
            withAnimation {
                currentFlow = nil
            }
            print("🏁 All flows completed, clearing current flow")
        }
    }
    
    /// Reset to no current flow and clear all pending transitions
    func reset() {
        currentFlow = nil
        pendingTransitions.removeAll()
        print("🔄 Flow manager reset")
    }
    
    // MARK: - Debug Helpers
    
    /// Get the number of pending flows (useful for debugging)
    var pendingFlowCount: Int {
        pendingTransitions.count
    }
    
    /// Get all pending flows (useful for debugging)
    var allPendingFlows: [AppFlow] {
        pendingTransitions
    }
}
