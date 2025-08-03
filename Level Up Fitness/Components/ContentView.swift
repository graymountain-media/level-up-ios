//
//  ContentView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/23/25.
//

import SwiftUI

struct PopoverTarget: Hashable {
    var id: Int
    var anchorPoint: UnitPoint
}

struct PopoverHandler: ViewModifier {
    @Binding var popoverTarget: PopoverTarget?
    var nsPopover: Namespace.ID
    
    func body(content: Content) -> some View {
        ZStack {
            content
            customPopover
                .transition(
                    .opacity
                    .animation(.easeIn)
                )
        }
        .foregroundStyle(.white)
        .contentShape(Rectangle())
        .onTapGesture {
            popoverTarget = nil
        }
    }
    
    private func showPopover(target: PopoverTarget) {
        if popoverTarget != nil {
            withAnimation {
                popoverTarget = nil
            } completion: {
                popoverTarget = target
            }
        } else {
            popoverTarget = target
        }
    }
    
    @ViewBuilder
    private var customPopover: some View {
        if let popoverTarget {
            ZStack {
                ZStack {
                    Color.black.opacity(0.2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                    Color.white.matchedGeometryEffect(
                        id: popoverTarget,
                        in: nsPopover,
                        properties: .frame,
                        anchor: .center,
                        isSource: false
                    )
                    .blendMode(.destinationOut)
                }
                .compositingGroup()
                Text("Popover for \(popoverTarget.id)")
                    .padding()
                    .foregroundStyle(.gray)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(white: 0.95))
                            .shadow(radius: 6)
                    }
                    .padding(40)
                    .padding(.horizontal)
                    .matchedGeometryEffect(
                        id: popoverTarget,
                        in: nsPopover,
                        properties: .position,
                        anchor: popoverTarget.anchorPoint,
                        isSource: false
                    )
            }
            .zIndex(1)
        }
    }
}
//struct ContentView: View {
//    @State private var popoverTarget: PopoverTarget?
//    @Namespace private var nsPopover
//
//    @ViewBuilder
//    private var customPopover: some View {
//        if let popoverTarget {
//            ZStack {
//                ZStack {
//                    Color.black.opacity(0.2)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .ignoresSafeArea()
//                    Color.white.matchedGeometryEffect(
//                        id: popoverTarget,
//                        in: nsPopover,
//                        properties: .frame,
//                        anchor: .center,
//                        isSource: false
//                    )
//                    .blendMode(.destinationOut)
//                }
//                .compositingGroup()
//                Text("Popover for \(popoverTarget)")
//                    .padding()
//                    .foregroundStyle(.gray)
//                    .background {
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(Color(white: 0.95))
//                            .shadow(radius: 6)
//                    }
//                    .padding(40)
//                    .padding(.horizontal)
//                    .matchedGeometryEffect(
//                        id: popoverTarget,
//                        in: nsPopover,
//                        properties: .position,
//                        anchor: popoverTarget.anchorForPopover,
//                        isSource: false
//                    )
//            }
//            .zIndex(1)
//        }
//    }
//
//    private func showPopover(target: PopoverTarget) {
//        if popoverTarget != nil {
//            withAnimation {
//                popoverTarget = nil
//            } completion: {
//                popoverTarget = target
//            }
//        } else {
//            popoverTarget = target
//        }
//    }
//
//    var body: some View {
//        ZStack {
//            
//            customPopover
//                .transition(
//                    .opacity
//                    .animation(.easeIn)
//                )
//        }
//        .foregroundStyle(.white)
//        .contentShape(Rectangle())
//        .onTapGesture {
//            popoverTarget = nil
//        }
//    }
//}

struct SomeView: View {
    @State var popoverTarget: PopoverTarget?
    @Namespace private var nsPopover
    let targets: [PopoverTarget] = [
        .init(id: 1, anchorPoint: .bottom),
        .init(id: 2, anchorPoint: .topTrailing),
        .init(id: 3, anchorPoint: .topLeading),
    ]
    
    var body: some View {
        VStack {
            Text("Text 1")
                .padding()
                .background(.blue)
                .onTapGesture { popoverTarget = targets[0]  }
                .matchedGeometryEffect(id: targets[0].id, in: nsPopover)
                .padding(.top, 50)
                .padding(.leading, 100)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Text 2")
                .padding()
                .background(.orange)
                .onTapGesture { popoverTarget = targets[1] }
                .matchedGeometryEffect(id: targets[1].id, in: nsPopover)
                .padding(.top, 100)
                .padding(.trailing, 40)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Spacer()

            Text("Text 3")
                .padding()
                .background(.green)
                .onTapGesture { popoverTarget = targets[2] }
                .matchedGeometryEffect(id: targets[2].id, in: nsPopover)
                .padding(.bottom, 250)
        }
        .modifier(PopoverHandler(popoverTarget: $popoverTarget, nsPopover: nsPopover))
    }
}

#Preview {
    SomeView()
}
