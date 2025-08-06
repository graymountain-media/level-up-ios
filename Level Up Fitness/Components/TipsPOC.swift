//
//  TipsPOC.swift
//  Level Up
//
//  Created by Jake Gray on 8/4/25.
//

import SwiftUI
import TipKit

struct FirstTip: Tip {
    var title: Text = Text("First")
}
struct SecondTip: Tip {
    var title: Text = Text("Second")
}
struct ThirdTip: Tip {
    var title: Text = Text("Third")
}
struct FourthTip: Tip {
    var title: Text = Text("Fourth")
}

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
            Text("First")
                .messageSource(id: 0, nameSpace: namespace)
            Text("Second")
                .messageSource(id: 1, nameSpace: namespace)
            Text("Third")
                .messageSource(id: 2, nameSpace: namespace)
            Text("Fourth")
                .messageSource(id: 3, nameSpace: namespace)
                
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .messageOverlay(namespace: namespace, manager: manager)
        .onAppear {
            manager.startTips()
        }
    }
    
    
}

extension View {
    func messageOverlay(namespace: Namespace.ID, manager: SequentialTipsManager) -> some View {
        self.modifier(MessageOverlayModifier(namespace: namespace, manager: manager))
    }
    
    func messageSource(id: Int, nameSpace: Namespace.ID, anchorPoint: UnitPoint = .top) -> some View {
        self.modifier(MessageSourceModifier(id: id, namespace: nameSpace, anchorPoint: anchorPoint))
    }
}

struct MessageSourceModifier: ViewModifier {
    var id: Int
    var namespace: Namespace.ID
    var anchorPoint: UnitPoint
    
    func body(content: Content) -> some View {
        content
            .matchedGeometryEffect(id: id, in: namespace, properties: .frame, anchor: anchorPoint)
    }
}

struct MessageOverlayModifier: ViewModifier {
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
                if let tip = manager.currentTip {
                    ZStack {
                        ZStack {
                            Color.black
                                .opacity(0.3)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea()
                            RoundedRectangle(cornerRadius: 12)
                                .padding(-10)
                                .matchedGeometryEffect(id: tip.id, in: namespace, properties: .frame, anchor: tip.position, isSource: false)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                        .onTapGesture {
                            manager.nextTip()
                        }
                            
                        TipPopoverView(tip: tip, manager: manager)
                            .matchedGeometryEffect(id: tip.id, in: namespace, properties: .position, anchor: oppositeAnchor(tip.position), isSource: false)
                    }
                    
                }
            }
        
            .animation(.easeInOut(duration: 0.2), value: manager.currentTip)
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
