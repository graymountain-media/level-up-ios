//
//  FlowManagerTestView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/10/25.
//

import SwiftUI
import FactoryKit

/// A testing view to manually verify AppFlowManager behavior
struct FlowManagerTestView: View {
    @Injected(\.appFlowManager) var flowManager
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var transitionLog: [String] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    currentStateSection
                    actionButtonsSection
                    transitionLogSection
                }
                .padding()
            }
            .navigationTitle("Flow Manager Test")
            .navigationBarItems(trailing: clearLogButton)
        }
        .alert("Flow Manager", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: flowManager.currentFlow) { oldFlow, newFlow in
            logTransition(from: oldFlow, to: newFlow)
        }
//        .onChange(of: flowManager.) { oldCount, newCount in
//            if newCount > oldCount {
//                print("Queued flow - now \(newCount) pending")
//            } else if newCount < oldCount {
//                print("Processed flow - \(newCount) remaining")
//            }
//        }
    }
    
    // MARK: - Current State Section
    
    private var currentStateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current State")
                .font(.headline)
                .foregroundColor(.primary)
            
            StateIndicator(
                title: "Current Flow",
                value: flowStateString,
                isActive: flowManager.currentFlow != nil
            )
            
//            StateIndicator(
//                title: "Pending Flows",
//                value: "\(flowManager.pendingFlowCount) queued",
//                isActive: flowManager.pendingFlowCount > 0
//            )
            
            if let currentFlow = flowManager.currentFlow {
                switch currentFlow {
                case .levelUp(let notification):
                    StateIndicator(
                        title: "Level Up Details",
                        value: "Level \(notification.toLevel)",
                        isActive: true
                    )
                case .pathAssignment(let path):
                    StateIndicator(
                        title: "Path Assignment",
                        value: path.rawValue,
                        isActive: true
                    )
                case .factionSelection:
                    StateIndicator(
                        title: "Faction Selection",
                        value: "Active",
                        isActive: true
                    )
                }
            }
            
            // Show pending flows breakdown
//            if flowManager.pendingFlowCount > 0 {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Pending Queue:")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    ForEach(Array(flowManager.allPendingFlows.enumerated()), id: \.offset) { index, flow in
//                        Text("\(index + 1). \(flowDescription(flow))")
//                            .font(.caption2)
//                            .foregroundColor(.primary)
//                    }
//                }
//                .padding(.top, 8)
//            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Action Buttons Section
    
    private var actionButtonsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Test Actions")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // Queue Tests
                TestButton("Queue Level Up") {
                    testQueueLevelUp()
                }
                
                TestButton("Queue Path") {
                    testQueuePath()
                }
                
                TestButton("Queue Faction") {
                    testQueueFaction()
                }
                
                TestButton("Next Flow") {
                    testNextFlow()
                }
                
                // Complex Flows
                TestButton("Queue Full Flow") {
                    testQueueFullFlow()
                }
                
                TestButton("Queue Multiple") {
                    testQueueMultiple()
                }
                
                TestButton("Priority Test") {
                    testPriorityOrder()
                }
                
                TestButton("Replace Flow") {
                    testReplaceFlow()
                }
                
                // Edge Cases
                TestButton("Next (Empty)") {
                    testNextFlowEmpty()
                }
                
                TestButton("Queue Duplicate") {
                    testQueueDuplicate()
                }
                
                TestButton("Mixed Priority") {
                    testMixedPriority()
                }
                
                TestButton("Reset All") {
                    testReset()
                }
            }
        }
    }
    
    // MARK: - Transition Log Section
    
    private var transitionLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Transition Log")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(transitionLog.count) entries")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if transitionLog.isEmpty {
                Text("No transitions yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(transitionLog.indices.reversed(), id: \.self) { index in
                        HStack {
                            Text("\(transitionLog.count - index).")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 30, alignment: .leading)
                            
                            Text(transitionLog[index])
                                .font(.caption)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(index == transitionLog.count - 1 ? Color.blue.opacity(0.1) : Color.clear)
                        .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var clearLogButton: some View {
        Button("Clear") {
            transitionLog.removeAll()
        }
    }
    
    // MARK: - Test Functions
    
    private func testQueueLevelUp() {
        let notification = createTestNotification(level: 5)
        flowManager.queueFlow(.levelUp(notification))
        showAlert("Queued level up to level 5")
    }
    
    private func testQueuePath() {
        flowManager.queueFlow(.pathAssignment(.hunter))
        showAlert("Queued path assignment (Hunter)")
    }
    
    private func testQueueFaction() {
        flowManager.queueFlow(.factionSelection)
        showAlert("Queued faction selection")
    }
    
    private func testNextFlow() {
        flowManager.nextFlow()
        showAlert("Advanced to next flow")
    }
    
    private func testQueueFullFlow() {
        let notification = createTestNotification(level: 15, hasPath: true, path: .hunter, hasFaction: true)
        flowManager.queueFlow(.levelUp(notification))
        showAlert("Queued full flow (Level Up + Path + Faction)")
    }
    
    private func testQueueMultiple() {
        flowManager.queueFlow(.factionSelection)
        flowManager.queueFlow(.pathAssignment(.hunter))
        let notification = createTestNotification(level: 8)
        flowManager.queueFlow(.levelUp(notification))
        showAlert("Queued multiple flows (different types)")
    }
    
    private func testPriorityOrder() {
        // Queue in wrong order to test priority
        flowManager.queueFlow(.factionSelection) // Priority 1
        flowManager.queueFlow(.pathAssignment(.hunter)) // Priority 2
        let notification = createTestNotification(level: 5)
        flowManager.queueFlow(.levelUp(notification)) // Priority 3
        showAlert("Queued flows in wrong order - should reorder by priority")
    }
    
    private func testReplaceFlow() {
        let notification1 = createTestNotification(level: 5)
        let notification2 = createTestNotification(level: 7)
        
        flowManager.queueFlow(.levelUp(notification1))
        flowManager.queueFlow(.levelUp(notification2))
        showAlert("Queued two level ups (second should replace first)")
    }
    
    private func testNextFlowEmpty() {
        flowManager.nextFlow()
        showAlert("Called nextFlow() with empty queue")
    }
    
    private func testQueueDuplicate() {
        flowManager.queueFlow(.factionSelection)
        flowManager.queueFlow(.factionSelection)
        showAlert("Queued duplicate faction selection (should dedupe)")
    }
    
    private func testMixedPriority() {
        // Test complex priority mixing
        flowManager.queueFlow(.factionSelection)
        let notification1 = createTestNotification(level: 10, hasPath: true, path: .hunter)
        flowManager.queueFlow(.levelUp(notification1))
        flowManager.queueFlow(.pathAssignment(.hunter))
        showAlert("Queued mixed priorities with auto-queuing")
    }
    
    private func testReset() {
        flowManager.reset()
        transitionLog.removeAll()
        showAlert("Reset all flows and log")
    }
    
    // MARK: - Helper Functions
    
    private var flowStateString: String {
        guard let currentFlow = flowManager.currentFlow else {
            return "No Active Flow"
        }
        
        switch currentFlow {
        case .levelUp(let notification):
            return "Level Up (Level \(notification.toLevel))"
        case .pathAssignment(let path):
            return "Path Assignment (\(path.rawValue))"
        case .factionSelection:
            return "Faction Selection"
        }
    }
    
    private func flowDescription(_ flow: AppFlow) -> String {
        switch flow {
        case .levelUp(let notification):
            return "Level Up (\(notification.toLevel))"
        case .pathAssignment(let path):
            return "Path (\(path.rawValue))"
        case .factionSelection:
            return "Faction Selection"
        }
    }
    
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
            unlockedContent: unlockedContent
        )
    }
    
    private func logTransition(from oldFlow: AppFlow?, to newFlow: AppFlow?) {
        let timestamp = DateFormatter.timeFormatter.string(from: Date())
        let logEntry = "\(timestamp): \(flowStateDescription(oldFlow)) → \(flowStateDescription(newFlow))"
        transitionLog.append(logEntry)
        
        // Keep only last 50 entries to prevent memory issues
        if transitionLog.count > 50 {
            transitionLog.removeFirst()
        }
    }
    
    private func flowStateDescription(_ flow: AppFlow?) -> String {
        guard let flow = flow else {
            return "None"
        }
        
        switch flow {
        case .levelUp(let notification):
            return "LevelUp(\(notification.toLevel))"
        case .pathAssignment(let path):
            return "Path(\(path.rawValue))"
        case .factionSelection:
            return "Faction"
        }
    }
    
    private func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
}

// MARK: - Supporting Views

struct StateIndicator: View {
    let title: String
    let value: String
    let isActive: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(isActive ? .bold : .regular)
                .foregroundColor(isActive ? .green : .primary)
        }
        .padding(.vertical, 2)
    }
}

struct TestButton: View {
    let title: String
    let action: () -> Void
    
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(8)
        }
    }
}

// MARK: - Extensions

private extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}

// MARK: - Preview

#Preview {
    FlowManagerTestView()
}
