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

struct FactionBackgroundModifier: ViewModifier {
    let faction: Faction?
    
    func body(content: Content) -> some View {
        let bg = switch(faction) {
        case .echoreach: "main_bg" // TODO: add faction bg once we have the image asset
        case .neurospire: "neurospire_bg"
        case .pulseforge: "pulseforge_bg"
        case .voidkind: "voidkind_bg"
        default: "main_bg"
        }
        content
            .background(
                Image(bg)
                    .resizable()
                    .ignoresSafeArea()
            )
    }
}

extension View {
    func borderShadow() -> some View {
        self.modifier(BoderShadowModifier())
    }
    
    func mainBackground() -> some View {
        self.modifier(MainBackgroundModifier())
    }
    
    func factionBackground(faction: Faction?) -> some View {
        self.modifier(FactionBackgroundModifier(faction: faction))
    }
}
