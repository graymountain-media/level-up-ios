//
//  TipsPOC.swift
//  Level Up
//
//  Created by Jake Gray on 8/4/25.
//

import SwiftUI
import TipKit

struct TipContent: Equatable {
    let id: Int
    let title: String
    let message: String
    let position: UnitPoint
    var requiresTap: Bool = false
}



struct TipsPOC: View {
    @Namespace var namespace
    
    @State var manager = SequentialTipsManager(
        tips: [
            TipContent(
                id: 0,
                title: "Welcome to the Nexus",
                message: "The Nexus is an elite academy that trains the next generation of warriors to fight the Invasion. Recruits like you are desperately needed!\n\nKeep reading to learn how your time at the Nexus will work.",
                position: .bottom,
                requiresTap: true
            ),
            TipContent(
                id: 1,
                title: "Experience Points (XP)",
                message: "You gain experience points by logging training sessions. 1 minute of exercise = 1 XP. You must work out a minimum of 20 minutes and can only log a maximum of 60 minutes per day.",
                position: .bottom
            ),
            TipContent(
                id: 2,
                title: "Your Level",
                message: "Gaining XP levels you up. Leveling up grants you access to powerful rewards.",
                position: .bottom
            ),
            TipContent(
                id: 3,
                title: "Your Avatar",
                message: "This is you. It represents your progress toward becoming the elite soldier that the Nexus, and humanity, needs.",
                position: .top
            )
        ],
        storageKey: "tips_completed"
    )

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                Rectangle()
                    .fill(.red)
                    .frame(width: 100, height: 40)
            }
            Text("Second")
                .foregroundStyle(.white)
                .tipSource(id: 1, nameSpace: namespace, manager: manager, anchorPoint: .bottom)
            Text("Third")
                .foregroundStyle(.white)
                .tipSource(id: 2, nameSpace: namespace, manager: manager)
            Text("Fourth")
                .foregroundStyle(.white)
                .tipSource(id: 3, nameSpace: namespace, manager: manager)
                
        }
        .padding(40)
        .background(Color.major)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .tipOverlay(namespace: namespace, manager: manager)
        .onAppear {
            manager.forceStartTips()
        }
    }
    
    
}

extension View {
    func tipOverlay(
        namespace: Namespace.ID,
        manager: SequentialTipsManager
    ) -> some View {
        self.modifier(TipOverlayModifier(namespace: namespace, manager: manager))
    }
    
    func tipSource(
        id: Int,
        nameSpace: Namespace.ID,
        manager: SequentialTipsManager,
        anchorPoint: UnitPoint = .top,
        captureView: Bool = true
    ) -> some View {
        if captureView {
            manager.captureView(id: id, view: self)
        }
        return self.modifier(
            TipSourceModifier(
                id: id,
                namespace: nameSpace,
                manager: manager,
                anchorPoint: anchorPoint
            )
        )
    }
}

extension View where Self: Equatable {
    func equatableTipSource(
        id: Int,
        nameSpace: Namespace.ID,
        manager: SequentialTipsManager,
        anchorPoint: UnitPoint = .top
    ) -> some View {
        manager.captureEquatableView(id: id, view: self)
        return self.modifier(
            TipSourceModifier(
                id: id,
                namespace: nameSpace,
                manager: manager,
                anchorPoint: anchorPoint
            )
        )
    }
}

struct TipSourceModifier: ViewModifier {
    var id: Int
    var namespace: Namespace.ID
    var anchorPoint: UnitPoint
    var manager: SequentialTipsManager
     
    init(id: Int, namespace: Namespace.ID, manager: SequentialTipsManager, anchorPoint: UnitPoint) {
        self.id = id
        self.namespace = namespace
        self.manager = manager
        self.anchorPoint = anchorPoint
        
    }
    func body(content: Content) -> some View {
        content
            .matchedGeometryEffect(id: id, in: namespace, properties: .frame, anchor: anchorPoint, isSource: true)
            .matchedGeometryEffect(id: id+1000, in: namespace, properties: .frame, anchor: .center, isSource: true)
    }
}

struct TipOverlayModifier: ViewModifier {
    var namespace: Namespace.ID
    var manager: SequentialTipsManager
    
    func oppositeAnchor(_ anchor: UnitPoint) -> UnitPoint {
        switch anchor {
        case .top:
            return .bottom
        case .bottom:
            return .top
        case .bottomLeading:
            return .topTrailing
        case .bottomTrailing:
            return .topLeading
        case .topTrailing:
            return .bottomLeading
        case .topLeading:
            return .bottomTrailing
        default:
            return anchor
        }
    }
    func body(content: Content) -> some View {
        content
            .overlay {
                if let tip = manager.currentTip {
                    ZStack {
                        ZStack {
                            Color.black
                                .opacity(0.7)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea()
//                            RoundedRectangle(cornerRadius: 12)
//                                .padding(-10)
//                                .matchedGeometryEffect(id: tip.id, in: namespace, properties: .frame, anchor: tip.position, isSource: false)
//                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                        .onTapGesture {
                            if !tip.requiresTap {
                                manager.nextTip()
                            }
                        }
                        if let view = manager.capturedViews[tip.id] {
                            AnyView(view)
                                .matchedGeometryEffect(id: tip.id + 1000, in: namespace, properties: .frame, anchor: .center, isSource: false)
                                .simultaneousGesture(TapGesture().onEnded {manager.nextTip()}
                                )
                        }
                        if !tip.title.isEmpty {
                            HStack {
                                Spacer()
                                TipPopoverView(tip: tip, manager: manager)
                                    .matchedGeometryEffect(id: tip.id, in: namespace, properties: .position, anchor: oppositeAnchor(tip.position), isSource: false)
                                    .onTapGesture {
                                        if !tip.requiresTap {
                                            manager.nextTip()
                                        }
                                    }
                                Spacer()
                            }
                            .padding(16)
                        }
                    }
                    
                }
            }
            .animation(.easeInOut(duration: 0.2), value: manager.currentTip)
            .zIndex(99)
    }
}

#Preview {
    TipsPOC()
        .task {
            
            try? await Tips.resetDatastore()
            try? await Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
}
