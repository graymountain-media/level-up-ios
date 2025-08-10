//
//  AppFlowManagerTests.swift
//  Level Up FitnessTests
//
//  Created by Jake Gray on 8/10/25.
//

import XCTest
@testable import Level_Up_Fitness

@MainActor
final class AppFlowManagerTests: XCTestCase {
    
    var flowManager: AppFlowManager!
    
    override func setUp() {
        super.setUp()
        flowManager = AppFlowManager()
    }
    
    override func tearDown() {
        flowManager = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertEqual(flowManager.currentFlow, .idle)
        XCTAssertFalse(flowManager.isShowingLevelUp)
        XCTAssertFalse(flowManager.isShowingPathAssignment)
        XCTAssertFalse(flowManager.isShowingFactionSelection)
        XCTAssertNil(flowManager.currentLevelUpNotification)
        XCTAssertNil(flowManager.currentPathAssignment)
    }
    
    // MARK: - Basic Transition Tests
    
    func testTransitionFromIdleToLevelUp() {
        let notification = createMockLevelUpNotification(level: 5)
        
        flowManager.transitionTo(.showingLevelUp(notification))
        
        XCTAssertEqual(flowManager.currentFlow, .showingLevelUp(notification))
        XCTAssertTrue(flowManager.isShowingLevelUp)
        XCTAssertEqual(flowManager.currentLevelUpNotification?.newLevel, 5)
    }
    
    func testTransitionFromIdleToPathAssignment() {
        flowManager.transitionTo(.showingPathAssignment(.hunter))
        
        XCTAssertEqual(flowManager.currentFlow, .showingPathAssignment(.hunter))
        XCTAssertTrue(flowManager.isShowingPathAssignment)
        XCTAssertEqual(flowManager.currentPathAssignment, .hunter)
    }
    
    func testTransitionFromIdleToFactionSelection() {
        flowManager.transitionTo(.showingFactionSelection)
        
        XCTAssertEqual(flowManager.currentFlow, .showingFactionSelection)
        XCTAssertTrue(flowManager.isShowingFactionSelection)
    }
    
    func testReturnToIdle() {
        flowManager.transitionTo(.showingFactionSelection)
        flowManager.transitionTo(.idle)
        
        XCTAssertEqual(flowManager.currentFlow, .idle)
        XCTAssertFalse(flowManager.isShowingFactionSelection)
    }
    
    // MARK: - Natural Flow Progression Tests
    
    func testLevelUpToPathAssignmentProgression() {
        let notification = createMockLevelUpNotification(level: 4, hasPathAssignment: true, newPath: .guardian)
        
        // Start with level up
        flowManager.transitionTo(.showingLevelUp(notification))
        XCTAssertTrue(flowManager.isShowingLevelUp)
        
        // Should allow progression to path assignment
        flowManager.transitionTo(.showingPathAssignment(.guardian))
        XCTAssertEqual(flowManager.currentFlow, .showingPathAssignment(.guardian))
        XCTAssertTrue(flowManager.isShowingPathAssignment)
    }
    
    func testLevelUpToFactionSelectionProgression() {
        let notification = createMockLevelUpNotification(level: 15, hasFactionUnlock: true)
        
        // Start with level up
        flowManager.transitionTo(.showingLevelUp(notification))
        XCTAssertTrue(flowManager.isShowingLevelUp)
        
        // Should allow progression to faction selection
        flowManager.transitionTo(.showingFactionSelection)
        XCTAssertEqual(flowManager.currentFlow, .showingFactionSelection)
        XCTAssertTrue(flowManager.isShowingFactionSelection)
    }
    
    func testPathAssignmentToFactionSelectionProgression() {
        // Start with path assignment
        flowManager.transitionTo(.showingPathAssignment(.hunter))
        XCTAssertTrue(flowManager.isShowingPathAssignment)
        
        // Should allow progression to faction selection
        flowManager.transitionTo(.showingFactionSelection)
        XCTAssertEqual(flowManager.currentFlow, .showingFactionSelection)
        XCTAssertTrue(flowManager.isShowingFactionSelection)
    }
    
    // MARK: - Queue Level Up Tests
    
    func testQueueLevelUpWithNoExtras() {
        let notification = createMockLevelUpNotification(level: 3)
        
        flowManager.queueLevelUp(notification)
        
        XCTAssertEqual(flowManager.currentFlow, .showingLevelUp(notification))
        XCTAssertTrue(flowManager.isShowingLevelUp)
    }
    
    func testQueueLevelUpWithPathAssignment() {
        let notification = createMockLevelUpNotification(level: 4, hasPathAssignment: true, newPath: .guardian)
        
        flowManager.queueLevelUp(notification)
        
        XCTAssertEqual(flowManager.currentFlow, .showingLevelUp(notification))
        XCTAssertTrue(flowManager.isShowingLevelUp)
    }
    
    func testQueueLevelUpWithFactionUnlock() {
        let notification = createMockLevelUpNotification(level: 15, hasFactionUnlock: true)
        
        flowManager.queueLevelUp(notification)
        
        XCTAssertEqual(flowManager.currentFlow, .showingLevelUp(notification))
        XCTAssertTrue(flowManager.isShowingLevelUp)
    }
    
    // MARK: - Dismiss and Continue Tests
    
    func testDismissLevelUpWithNoFollow ups() async {
        let notification = createMockLevelUpNotification(level: 3)
        flowManager.transitionTo(.showingLevelUp(notification))
        
        flowManager.dismissCurrentAndContinue()
        
        XCTAssertEqual(flowManager.currentFlow, .idle)
    }
    
    func testDismissLevelUpWithPathAssignment() async {
        let notification = createMockLevelUpNotification(level: 4, hasPathAssignment: true, newPath: .guardian)
        flowManager.queueLevelUp(notification)
        
        flowManager.dismissCurrentAndContinue()
        
        // Should transition to path assignment
        XCTAssertEqual(flowManager.currentFlow, .showingPathAssignment(.guardian))
        XCTAssertTrue(flowManager.isShowingPathAssignment)
    }
    
    func testDismissLevelUpWithFactionUnlock() async {
        let notification = createMockLevelUpNotification(level: 15, hasFactionUnlock: true)
        flowManager.queueLevelUp(notification)
        
        flowManager.dismissCurrentAndContinue()
        
        // Should transition to faction selection
        XCTAssertEqual(flowManager.currentFlow, .showingFactionSelection)
        XCTAssertTrue(flowManager.isShowingFactionSelection)
    }
    
    func testDismissPathAssignment() {
        flowManager.transitionTo(.showingPathAssignment(.hunter))
        
        flowManager.dismissCurrentAndContinue()
        
        XCTAssertEqual(flowManager.currentFlow, .idle)
    }
    
    func testDismissFactionSelection() {
        flowManager.transitionTo(.showingFactionSelection)
        
        flowManager.dismissCurrentAndContinue()
        
        XCTAssertEqual(flowManager.currentFlow, .idle)
    }
    
    // MARK: - Invalid Transition Tests
    
    func testInvalidTransitionFromLevelUpToFactionWithoutDismiss() {
        let notification = createMockLevelUpNotification(level: 5)
        flowManager.transitionTo(.showingLevelUp(notification))
        
        // Try to transition directly to faction selection (should queue instead)
        flowManager.transitionTo(.showingPathAssignment(.hunter))
        
        // Should remain in level up state
        XCTAssertTrue(flowManager.isShowingLevelUp)
    }
    
    // MARK: - Reset Tests
    
    func testReset() {
        let notification = createMockLevelUpNotification(level: 5)
        flowManager.queueLevelUp(notification)
        
        flowManager.reset()
        
        XCTAssertEqual(flowManager.currentFlow, .idle)
        XCTAssertFalse(flowManager.isShowingLevelUp)
        XCTAssertFalse(flowManager.isShowingPathAssignment)
        XCTAssertFalse(flowManager.isShowingFactionSelection)
    }
    
    // MARK: - Concurrent Transition Tests
    
    func testQueuedTransitionsProcessInOrder() async {
        let notification = createMockLevelUpNotification(level: 4, hasPathAssignment: true, newPath: .guardian)
        
        // Queue level up (which should also queue path assignment)
        flowManager.queueLevelUp(notification)
        XCTAssertTrue(flowManager.isShowingLevelUp)
        
        // Dismiss level up
        flowManager.dismissCurrentAndContinue()
        
        // Give time for async transition
        try? await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        
        // Should now be showing path assignment
        XCTAssertTrue(flowManager.isShowingPathAssignment)
        XCTAssertEqual(flowManager.currentPathAssignment, .guardian)
    }
    
    // MARK: - Edge Case Tests
    
    func testMultipleLevelUpNotifications() {
        let notification1 = createMockLevelUpNotification(level: 5)
        let notification2 = createMockLevelUpNotification(level: 6)
        
        flowManager.queueLevelUp(notification1)
        XCTAssertEqual(flowManager.currentLevelUpNotification?.newLevel, 5)
        
        // Second notification should replace the first
        flowManager.queueLevelUp(notification2)
        XCTAssertEqual(flowManager.currentLevelUpNotification?.newLevel, 6)
    }
    
    func testAppFlowEquality() {
        let notification1 = createMockLevelUpNotification(level: 5)
        let notification2 = createMockLevelUpNotification(level: 5)
        let notification3 = createMockLevelUpNotification(level: 6)
        
        XCTAssertEqual(AppFlow.showingLevelUp(notification1), AppFlow.showingLevelUp(notification2))
        XCTAssertNotEqual(AppFlow.showingLevelUp(notification1), AppFlow.showingLevelUp(notification3))
        XCTAssertEqual(AppFlow.showingPathAssignment(.hunter), AppFlow.showingPathAssignment(.hunter))
        XCTAssertNotEqual(AppFlow.showingPathAssignment(.hunter), AppFlow.showingPathAssignment(.guardian))
    }
    
    // MARK: - Helper Methods
    
    private func createMockLevelUpNotification(
        level: Int,
        hasPathAssignment: Bool = false,
        hasFactionUnlock: Bool = false,
        newPath: HeroPath? = nil
    ) -> LevelUpNotification {
        var unlockedContent: [UnlockableContent] = []
        
        if hasPathAssignment {
            unlockedContent.append(.missions) // Assuming missions unlock with path
        }
        
        if hasFactionUnlock {
            unlockedContent.append(.factions)
        }
        
        return LevelUpNotification(
            fromLevel: level - 1,
            toLevel: level,
            unlockedContent: unlockedContent,
            hasPathAssignment: hasPathAssignment,
            hasFactionUnlock: hasFactionUnlock,
            newPath: newPath
        )
    }
}

// MARK: - Performance Tests

extension AppFlowManagerTests {
    
    func testPerformanceOfMultipleTransitions() {
        measure {
            for i in 1...100 {
                let notification = createMockLevelUpNotification(level: i)
                flowManager.queueLevelUp(notification)
                flowManager.dismissCurrentAndContinue()
                flowManager.reset()
            }
        }
    }
    
    func testPerformanceOfStateChecks() {
        let notification = createMockLevelUpNotification(level: 5)
        flowManager.queueLevelUp(notification)
        
        measure {
            for _ in 1...1000 {
                _ = flowManager.isShowingLevelUp
                _ = flowManager.isShowingPathAssignment
                _ = flowManager.isShowingFactionSelection
                _ = flowManager.currentLevelUpNotification
                _ = flowManager.currentPathAssignment
            }
        }
    }
}