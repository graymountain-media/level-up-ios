//
//  LUButton.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/12/25.
//

import SwiftUI

struct LUButton: View {
    let title: String
    var isLoading: Bool = false
    var fillSpace: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
        }
        .buttonStyle(LUButtonStyle(isLoading: isLoading, fillSpace: fillSpace))
    }
}

struct LUButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    var isLoading: Bool = false
    var fillSpace: Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isLoading ? .clear : .major)
            .font(Font.mainFont(size: 24))
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .frame(maxWidth: fillSpace ? .infinity : nil)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .padding(.top, 4)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(
                            LinearGradient(colors: [.textOrange, .goldDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.major, lineWidth: 1.1)
                        .padding(2)
                }
            )
            .padding(1)
            .drawingGroup()
            .opacity(isEnabled ? 1 : 0.5)
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.major)
                }
            }
    }
}

#Preview {
    ZStack {
        Color.major.ignoresSafeArea()
        LUButton(title: "Quit", fillSpace: false, action: {
            print("Pressed")
        })
    }
}
