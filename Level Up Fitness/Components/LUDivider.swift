//
//  LUDivider.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/18/25.
//

import SwiftUI

struct LUDivider: View {
    var color: Color = .textOrange
    var lineWidth: CGFloat = 1
    var dotSize: CGFloat = 6
    var diamondWidth: CGFloat = 16
    var diamondHeight: CGFloat = 6
    
    var body: some View {
        ZStack(alignment: .center) {
            Diamond()
                .fill(
                    LinearGradient(colors: [
                        color.opacity(0.2),
                        color.opacity(0.5),
                        color,
                        color.opacity(0.5),
                        color.opacity(0.2)
                    ], startPoint: .leading, endPoint: .trailing)
                )
                .frame(height: 2)
                .frame(maxWidth: .infinity)
            
            Diamond()
                .fill(color)
                .frame(width: 9, height: 5)
            
            Diamond()
                .fill(.white.opacity(0.3))
                .frame(width: 9, height: 6)
        }
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

// Modifier to add standard padding and sizing
extension LUDivider {
    func standard() -> some View {
        self
            .padding(.horizontal, 40)
            .padding(.vertical, 10)
    }
}

#Preview {
    ZStack {
        Color.major.ignoresSafeArea()
        VStack(spacing: 30) {
            Text("DIAMOND DIVIDERS")
                .font(.mainFont(size: 24))
                .foregroundStyle(Color.textOrange)
            
            // Standard orange divider
            VStack(spacing: 4) {
                Text("Standard")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                LUDivider()
                    .standard()
            }
            
            // White divider with larger dot
            VStack(spacing: 4) {
                Text("Larger Dot & Diamonds")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                LUDivider(color: .white, lineWidth: 2, dotSize: 10, diamondWidth: 20, diamondHeight: 8)
                    .padding(.horizontal, 60)
            }
            
            // Thin divider with small diamonds
            VStack(spacing: 4) {
                Text("Thin Line")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                LUDivider(color: .textOrange, lineWidth: 1, dotSize: 6, diamondWidth: 12, diamondHeight: 4)
                    .padding(.horizontal, 40)
            }
            
            // No dot, just diamonds
            VStack(spacing: 4) {
                Text("No Center Dot")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                LUDivider(color: .white, lineWidth: 1, dotSize: 0, diamondWidth: 16, diamondHeight: 6)
                    .padding(.horizontal, 50)
            }
        }
        .padding()
    }
}
