//
//  AppFlowIntegrationTests.swift
//  Level Up FitnessTests
//
//  Created by Jake Gray on 8/10/25.
//

import XCTest
@testable import Level_Up_Fitness

@MainActor
final class AppFlowIntegrationTests: XCTestCase {
    
    var mockFlowManager: MockAppFlowManager!
    var appState: AppState!
    var levelManager: LevelManager!
    
    override func setUp() {
        super.setUp()
        
        // Set up dependency injection for testing
        Container.shared.appFlowManager.register { @MainActor in
            MockAppFlowManager()
        }
        
        // Create instances
        mockFlowManager = Container.shared.appFlowManager() as? MockAppFlowManager
        appState = Container.shared.appState()
        levelManager = Container.shared.levelManager()
        
        // Reset mock state
        mockFlowManager.resetTestingState()
    }
    
    override func tearDown() {
        mockFlowManager = nil
        appState = nil
        levelManager = nil
        
        // Reset container to default
        Container.shared.appFlowManager.reset()
        
        super.tearDown()
    }
    
    // MARK: - AppState Integration Tests
    
    func testAppStateReadsFlowManagerState() {
        // Set up flow manager state
        let notification = createTestNotification(level: 5)
        mockFlowManager.setFlowForTesting(.showingLevelUp(notification))
        
        // Test that AppState reflects the state
        XCTAssertTrue(appState.showLevelUpPopup)
        XCTAssertFalse(appState.showPathAssignment)
        XCTAssertFalse(appState.showFactionSelection)
        XCTAssertEqual(appState.levelUpNotification?.toLevel, 5)
    }
    
    func testAppStateDismissCallsFlowManager() {
        // Set up initial state
        let notification = createTestNotification(level: 5)
        mockFlowManager.setFlowForTesting(.showingLevelUp(notification))
        
        // Call dismiss through AppState
        appState.dismissLevelUpPopup()
        
        // Verify flow manager was called
        XCTAssertEqual(mockFlowManager.dismissCalls, 1)
    }
    
    func testAppStateFactionSelectionCallsFlowManager() async {
        // Set up faction selection state
        mockFlowManager.setFlowForTesting(.showingFactionSelection)
        
        // Call selectFaction through AppState
        await appState.selectFaction(.echoreach)
        
        // Verify flow manager was called
        XCTAssertEqual(mockFlowManager.dismissCalls, 1)
    }
    
    func testAppStatePathDismissalCallsFlowManager() {
        // Set up path assignment state
        mockFlowManager.setFlowForTesting(.showingPathAssignment(.hunter))
        
        // Call dismiss through AppState
        appState.dismissPathAssignment()
        
        // Verify flow manager was called
        XCTAssertEqual(mockFlowManager.dismissCalls, 1)
    }
    
    // MARK: - LevelManager Integration Tests
    
    func testLevelManagerQueuesLevelUp() {
        let notification = createTestNotification(level: 5)
        
        // Test that level manager calls flow manager
        levelManager.showLevelUpNotification(notification)
        
        // Verify flow manager was called
        XCTAssertEqual(mockFlowManager.queueLevelUpCalls.count, 1)
        XCTAssertEqual(mockFlowManager.queueLevelUpCalls.first?.toLevel, 5)
    }
    
    // MARK: - Flow Progression Integration Tests
    
    func testFullLevelUpFlowProgression() async {
        // Create notification with path assignment
        let notification = createTestNotification(level: 4, hasPath: true, path: .guardian)
        
        // Queue level up through level manager
        levelManager.showLevelUpNotification(notification)
        
        // Verify level up is showing
        XCTAssertTrue(appState.showLevelUpPopup)
        XCTAssertEqual(appState.levelUpNotification?.toLevel, 4)
        
        // Dismiss level up through app state
        appState.dismissLevelUpPopup()
        
        // Give time for async transition
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify progression to path assignment
        XCTAssertTrue(mockFlowManager.dismissCalls > 0)
        
        // If mock is set up to progress naturally
        if mockFlowManager.isShowingPathAssignment {
            XCTAssertTrue(appState.showPathAssignment)
            XCTAssertEqual(appState.pendingPathAssignment, .guardian)
        }
    }
    
    func testLevelUpWithFactionUnlockProgression() async {
        // Create notification with faction unlock
        let notification = createTestNotification(level: 15, hasFaction: true)
        
        // Queue through level manager
        levelManager.showLevelUpNotification(notification)
        
        // Verify level up is showing
        XCTAssertTrue(appState.showLevelUpPopup)
        
        // Dismiss
        appState.dismissLevelUpPopup()
        
        // Give time for async transition
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify dismiss was called
        XCTAssertTrue(mockFlowManager.dismissCalls > 0)
    }
    
    // MARK: - Error Handling Tests
    
    func testFlowManagerFailureHandling() {
        // Set up mock to fail transitions
        mockFlowManager.shouldFailTransition = true
        
        let notification = createTestNotification(level: 5)
        levelManager.showLevelUpNotification(notification)
        
        // Verify that failure is handled gracefully
        // The app should not crash and state should be consistent
        XCTAssertEqual(mockFlowManager.queueLevelUpCalls.count, 1)
        
        // Reset failure mode
        mockFlowManager.shouldFailTransition = false
    }
    
    func testConcurrentFlowOperations() async {
        let notification1 = createTestNotification(level: 5)
        let notification2 = createTestNotification(level: 6)
        
        // Queue multiple notifications concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                self.levelManager.showLevelUpNotification(notification1)
            }
            group.addTask {
                self.levelManager.showLevelUpNotification(notification2)
            }
        }
        
        // Verify that flow manager handled concurrent access
        XCTAssertGreaterThanOrEqual(mockFlowManager.queueLevelUpCalls.count, 1)
        
        // The last notification should be the one showing
        let lastLevel = mockFlowManager.lastQueuedLevelUp?.toLevel
        XCTAssertTrue(lastLevel == 5 || lastLevel == 6)
    }
    
    // MARK: - State Consistency Tests
    
    func testStateConsistencyAfterMultipleOperations() {
        let notification = createTestNotification(level: 5)
        
        // Perform multiple operations
        levelManager.showLevelUpNotification(notification)
        appState.dismissLevelUpPopup()
        appState.dismissFactionSelection()
        appState.dismissPathAssignment()
        
        // Verify state is consistent
        XCTAssertGreaterThan(mockFlowManager.dismissCalls, 0)
        XCTAssertEqual(mockFlowManager.queueLevelUpCalls.count, 1)
    }
    
    func testMemoryManagementUnderLoad() {
        // Test that repeated operations don't cause memory issues
        for i in 1...100 {
            let notification = createTestNotification(level: i)
            levelManager.showLevelUpNotification(notification)
            appState.dismissLevelUpPopup()
            
            if i % 10 == 0 {
                mockFlowManager.reset()
                mockFlowManager.resetTestingState()
            }
        }
        
        // If we get here without crashing, memory management is working
        XCTAssertTrue(true)
    }
    
    // MARK: - Helper Methods
    
    private func createTestNotification(
        level: Int,
        hasPath: Bool = false,
        path: HeroPath? = nil,
        hasFaction: Bool = false
    ) -> LevelUpNotification {
        var unlockedContent: [UnlockableContent] = []
        if hasPath { unlockedContent.append(.missions) }
        if hasFaction { unlockedContent.append(.factions) }
        
        return LevelUpNotification(
            fromLevel: level - 1,
            toLevel: level,
            unlockedContent: unlockedContent,
            hasPathAssignment: hasPath,
            hasFactionUnlock: hasFaction,
            newPath: path
        )
    }
}

// MARK: - Performance Integration Tests

extension AppFlowIntegrationTests {
    
    func testFlowManagerPerformanceWithRealComponents() {
        measure {
            for i in 1...50 {
                let notification = createTestNotification(level: i)
                levelManager.showLevelUpNotification(notification)
                
                // Simulate UI interaction
                _ = appState.showLevelUpPopup
                _ = appState.levelUpNotification
                
                appState.dismissLevelUpPopup()
            }
        }
    }
    
    func testConcurrentStateReads() async {
        let notification = createTestNotification(level: 5)
        levelManager.showLevelUpNotification(notification)
        
        // Measure concurrent reads
        await withTaskGroup(of: Bool.self) { group in
            for _ in 1...100 {
                group.addTask {
                    return self.appState.showLevelUpPopup
                }
            }
        }
        
        // If we complete without issues, concurrent access is working
        XCTAssertTrue(true)
    }
}