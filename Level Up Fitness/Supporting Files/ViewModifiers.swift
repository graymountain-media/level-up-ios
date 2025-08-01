//
//  ViewModifiers.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/12/25.
//

import SwiftUI

struct BoderShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black, radius: 2, x: 0, y: 2)
    }
}

struct ContainerBorderModifier: ViewModifier {
    var color: Color = .border
    func body(content: Content) -> some View {
        content
            .overlay {
                CustomBorderShape(cornerWidth: 18)
                    .stroke(color, lineWidth: 3)
                    .borderShadow()
                CustomBorderShape(cornerWidth: 15)
                    .stroke(color, lineWidth: 3)
                    .padding(8)
                    .borderShadow()
            }
    }
}

struct MainBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Image("main_bg")
                    .resizable()
                    .ignoresSafeArea()
            )
    }
}
extension View {
    func borderShadow() -> some View {
        self.modifier(BoderShadowModifier())
    }
    
    func containerBorder(color: Color = .border) -> some View {
        self.modifier(ContainerBorderModifier(color: color))
    }
    
    func mainBackground() -> some View {
        self.modifier(MainBackgroundModifier())
    }
}
