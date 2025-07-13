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
    func body(content: Content) -> some View {
        content
            .overlay {
                CustomBorderShape(cornerWidth: 18)
                    .stroke(Color.border, lineWidth: 3)
                    .borderShadow()
                CustomBorderShape(cornerWidth: 15)
                    .stroke(Color.border, lineWidth: 3)
                    .padding(8)
                    .borderShadow()
            }
    }
}

extension View {
    func borderShadow() -> some View {
        self.modifier(BoderShadowModifier())
    }
    
    func containerBorder() -> some View {
        self.modifier(ContainerBorderModifier())
    }
}
