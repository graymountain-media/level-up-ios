//
//  SequentialTipsManager.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/4/25.
//

import SwiftUI

// MARK: - Sequential Tips Manager
@Observable
class SequentialTipsManager {
    private(set) var currentTipIndex: Int = -1
    private let tips: [TipContent]
    private let storageKey: String
    private var singleTips: [String: TipContent] = [:]
    private var activeSingleTipKey: String?
    var capturedViews: [Int: any View] = [:]
    
    var currentTip: TipContent? {
        // Show active single tip if set, otherwise show sequential tip
        if let key = activeSingleTipKey, let singleTip = singleTips[key] {
            return singleTip
        }
        guard currentTipIndex >= 0 && currentTipIndex < tips.count else { return nil }
        return tips[currentTipIndex]
    }
    
    func captureView<V: View>(id: Int, view: V) {
        if capturedViews.contains(where: { $0.key == id }) {
            return
        }
        
        print("DEBUG: View captured for tip \(id)")
        capturedViews[id] = view
    }
    
    func captureEquatableView<V: View & Equatable>(id: Int, view: V) {
        print(view)
        if let capturedView = capturedViews[id] as? V, capturedView == view {
            print("DEBUG: View NOT CAPTURED for tip \(id)")
            return
        }
        print("DEBUG: View captured for tip \(id)")
        capturedViews[id] = view
    }
    
    var hasMoreTips: Bool {
        currentTipIndex < tips.count - 1
    }
    
    var isShowingTips: Bool {
        activeSingleTipKey != nil || (currentTipIndex >= 0 && currentTipIndex < tips.count)
    }
    
    init(tips: [TipContent], storageKey: String) {
        self.tips = tips
        self.storageKey = storageKey
        loadProgress()
    }
    
    func forceStartTips() {
        currentTipIndex = 0
    }
    
    func startTips() {
        guard !hasCompletedAllTips() else { return }
        currentTipIndex = 0
    }
    
    func nextTip() {
        // If showing a single tip, dismiss it
        if activeSingleTipKey != nil {
            dismissSingleTip()
            return
        }
        
        // Otherwise handle sequential tips
        if hasMoreTips {
            currentTipIndex += 1
        } else {
            completeTips()
        }
    }
    
    func skipTips() {
        if activeSingleTipKey != nil {
            dismissSingleTip()
        } else {
            completeTips()
        }
    }
    
    func resetTips() {
        let trackedKeys = UserDefaults.standard.stringArray(forKey: "tipKeys") ?? []
        for key in trackedKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.removeObject(forKey: "tipKeys")
        
        currentTipIndex = -1
        activeSingleTipKey = nil
    }
    
    // MARK: - Single Tip Methods
    func registerSingleTip(key: String, tip: TipContent) {
        singleTips[key] = tip
    }
    
    func registerSingleTip(key: String, id: Int, title: String, message: String, position: UnitPoint = .bottom) {
        let tip = TipContent(id: id, title: title, message: message, position: position)
        registerSingleTip(key: key, tip: tip)
    }
    
    func showSingleTip(key: String) {
        guard singleTips[key] != nil else { return }
        
        // Check if this single tip has already been shown
        let singleTipKey = "\(storageKey)_single_\(key)"
        guard !UserDefaults.standard.bool(forKey: singleTipKey) else { return }
        
        activeSingleTipKey = key
    }
    
    func forceShowTip(key: String) {
        guard singleTips[key] != nil else { return }
        
        activeSingleTipKey = key
    }
    
    func dismissSingleTip() {
        // Mark the single tip as completed when dismissed
        if let key = activeSingleTipKey {
            let singleTipKey = "\(storageKey)_single_\(key)"
            
            // Track this key for reset functionality
            var trackedKeys = UserDefaults.standard.stringArray(forKey: "tipKeys") ?? []
            if !trackedKeys.contains(singleTipKey) {
                trackedKeys.append(singleTipKey)
                UserDefaults.standard.set(trackedKeys, forKey: "tipKeys")
            }
            
            UserDefaults.standard.set(true, forKey: singleTipKey)
        }
        activeSingleTipKey = nil
    }
    
    private func completeTips() {
        currentTipIndex = -1
        
        // Track this key for reset functionality
        var trackedKeys = UserDefaults.standard.stringArray(forKey: "tipKeys") ?? []
        if !trackedKeys.contains(storageKey) {
            trackedKeys.append(storageKey)
            UserDefaults.standard.set(trackedKeys, forKey: "tipKeys")
        }
        
        UserDefaults.standard.set(true, forKey: storageKey)
    }
    
    private func hasCompletedAllTips() -> Bool {
        UserDefaults.standard.bool(forKey: storageKey)
    }
    
    private func loadProgress() {
        if hasCompletedAllTips() {
            currentTipIndex = -1
        }
    }
}

// MARK: - Tip Popover View
struct TipPopoverView: View {
    let tip: TipContent
    let manager: SequentialTipsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(tip.title)
                .font(.system(size: 16))
                .bold()
                .foregroundStyle(.textOrange)
            
            Text(tip.message)
                .font(.system(size: 12))
                .foregroundStyle(.white)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.major)
                .shadow(color: .white, radius: 8)
        )
        .padding(.vertical)
        .padding(.horizontal)
        .presentationBackground(.clear)
    }
}
