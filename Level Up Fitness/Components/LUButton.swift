//
//  LUButton.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/12/25.
//

import SwiftUI

enum LUButtonSize {
    case regular
    case small
}

struct LUButton: View {
    let title: String
    var isLoading: Bool = false
    var fillSpace: Bool = false
    var size: LUButtonSize = .regular
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
        }
        .buttonStyle(LUButtonStyle(isLoading: isLoading, fillSpace: fillSpace, size: size))
    }
}

struct LUButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    var isLoading: Bool = false
    var fillSpace: Bool = false
    var size: LUButtonSize
    
    var fontSize: CGFloat {
        switch size {
        case .regular:
            24
        case .small:
            17
        }
    }
    
    var horizontalPadding: CGFloat {
        switch size {
        case .regular:
            24
        case .small:
            12
        }
    }
    
    var verticalPadding: CGFloat {
        switch size {
        case .regular:
            8
        case .small:
            4
        }
    }
    
    var height: CGFloat {
        switch size {
        case .regular:
            46
        case .small:
            32
        }
    }
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isLoading ? .clear : .major)
            .font(Font.mainFont(size: fontSize))
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .frame(maxWidth: fillSpace ? .infinity : nil)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .padding(.top, size == .regular ? 4 : 2)
        
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
            .opacity(isEnabled ? 1 : 0.5)
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.major)
                }
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
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
