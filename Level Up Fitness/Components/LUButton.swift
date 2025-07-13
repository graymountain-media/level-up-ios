//
//  LUButton.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/12/25.
//

import SwiftUI

struct LUButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(title.uppercased()) { action() }
            .buttonStyle(LUButtonStyle())
    }
}

struct LUButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.major)
            .font(Font.mainFont(size: 24))
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .padding(.top, 4)
            .background(
                ZStack {
                    Color.textOrange
                    VStack {
                        if configuration.isPressed {
                            LinearGradient(colors: [
                                Color.black.opacity(0.1),
                                Color.black.opacity(0.0),
                                Color.white.opacity(0.1)
                            ], startPoint: .top, endPoint: .bottom)
                        } else {
                            LinearGradient(colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.0),
                                Color.black.opacity(0.1)
                            ], startPoint: .top, endPoint: .bottom)
                        }
                    }
                    CustomBorderShape()
                        .stroke(Color.major, lineWidth: 1)
                        .padding(3)
                }
            )
            .padding(1)
            .clipShape(CustomBorderShape(cornerWidth: 13))
            .drawingGroup()
            .shadow(color: .black, radius: 2, x: 0, y: 2)
    }
}

#Preview {
    ZStack {
        Color.major.ignoresSafeArea()
        LUButton(title: "Quit", action: {
            print("Pressed")
        })
    }
}
