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
}

struct TipsPOC: View {
    @Namespace var namespace
    @State var manager = SequentialTipsManager.avatarTips()

    var body: some View {
        VStack(spacing: 24) {
            Rectangle()
                .fill(.red)
                .frame(width: 100, height: 40)
                .tipSource(id: 0, nameSpace: namespace, manager: manager, anchorPoint: .bottom)
            Text("Second")
                .foregroundStyle(.white)
                .tipSource(id: 1, nameSpace: namespace, manager: manager, anchorPoint: .bottom)
            Text("Third")
                .foregroundStyle(.white)
                .tipSource(id: 2, nameSpace: namespace, manager: manager)
            Text("Fourth")
                .foregroundStyle(.white)
                .tipSource(id: 3, nameSpace: namespace, manager: manager, anchorPoint: .bottom)
                
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
        anchorPoint: UnitPoint = .top
    ) -> some View {
        // Capture the view before applying the modifier
        manager.captureView(id: id, view: self)
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
        default:
            return anchor
        }
    }
    func body(content: Content) -> some View {
        content
            .overlay {
                if let tip = manager.currentTip,
                    let view = manager.capturedViews.first(where: { $0.key == tip.id})?.value as? AnyView {
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
                            manager.nextTip()
                        }
                        view
                            .matchedGeometryEffect(id: tip.id, in: namespace, properties: .frame, anchor: tip.position, isSource: false)
                            .onTapGesture {
                                manager.nextTip()
                            }
                        TipPopoverView(tip: tip, manager: manager)
                            .matchedGeometryEffect(id: tip.id, in: namespace, properties: .position, anchor: oppositeAnchor(tip.position), isSource: false)
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
