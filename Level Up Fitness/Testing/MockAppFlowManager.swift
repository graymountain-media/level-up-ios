//
//  MockAppFlowManager.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/10/25.
//

import Foundation

/// Mock implementation of AppFlowManager for testing
@Observable
@MainActor
class MockAppFlowManager: AppFlowManagerProtocol {
    private(set) var currentFlow: AppFlow?
    private var pendingTransitions: [AppFlow] = []
    
    // Track method calls for testing
    var queueFlowCalls: [AppFlow] = []
    var nextFlowCalls: Int = 0
    var resetCalls: Int = 0
    
    // Control mock behavior
    var shouldFailQueue = false
    var shouldFailNext = false
    
    // MARK: - Protocol Implementation
    
    func queueFlow(_ flow: AppFlow) {
        queueFlowCalls.append(flow)
        
        guard !shouldFailQueue else {
            print("🚫 MockAppFlowManager: Queue blocked for testing")
            return
        }
        
        // Simple mock: just add to pending queue
        pendingTransitions.append(flow)
        print("📥 MockAppFlowManager: Queued \(flow)")
    }
    
    func nextFlow() {
        nextFlowCalls += 1
        
        guard !shouldFailNext else {
            print("🚫 MockAppFlowManager: NextFlow blocked for testing")
            return
        }
        
        if let nextFlow = pendingTransitions.first {
            pendingTransitions.removeFirst()
            currentFlow = nextFlow
            print("▶️ MockAppFlowManager: Started flow \(nextFlow)")
        } else {
            currentFlow = nil
            print("🏁 MockAppFlowManager: No more flows, cleared current")
        }
    }
    
    func reset() {
        resetCalls += 1
        currentFlow = nil
        pendingTransitions.removeAll()
        print("🔄 MockAppFlowManager: Reset completed")
    }
    
    // MARK: - Testing Helpers
    
    /// Reset all tracking data for fresh test
    func resetTestingState() {
        queueFlowCalls.removeAll()
        nextFlowCalls = 0
        resetCalls = 0
        shouldFailQueue = false
        shouldFailNext = false
        currentFlow = nil
        pendingTransitions.removeAll()
    }
    
    /// Manually set the flow state for testing
    func setFlowForTesting(_ flow: AppFlow?) {
        currentFlow = flow
    }
    
    /// Manually set pending transitions for testing
    func setPendingTransitionsForTesting(_ flows: [AppFlow]) {
        pendingTransitions = flows
    }
    
    /// Get the last queued flow
    var lastQueuedFlow: AppFlow? {
        queueFlowCalls.last
    }
    
    /// Check if a specific flow was queued
    func wasFlowQueued(_ flow: AppFlow) -> Bool {
        return queueFlowCalls.contains(flow)
    }
    
    /// Check if nextFlow was called
    var wasNextFlowCalled: Bool {
        nextFlowCalls > 0
    }
    
    /// Get pending flow count
    var pendingFlowCount: Int {
        pendingTransitions.count
    }
    
    /// Get all pending flows
    var allPendingFlows: [AppFlow] {
        pendingTransitions
    }
}