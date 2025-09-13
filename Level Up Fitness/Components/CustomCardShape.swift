//
//  CustomCardShape.swift
//  Level Up
//
//  Created by Jake Gray on 9/9/25.
//

import SwiftUI

// Octagonal shape to match the border design
struct CustomCardShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let cutSize: CGFloat = 10 // Size of the angled corners
        
        // Start from top-left corner (after the cut)
        path.move(to: CGPoint(x: cutSize, y: 0))
        
        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX - cutSize, y: 0))
        
        // Top-right angled corner
        path.addLine(to: CGPoint(x: rect.maxX, y: cutSize))
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cutSize))
        
        // Bottom-right angled corner
        path.addLine(to: CGPoint(x: rect.maxX - cutSize, y: rect.maxY))
        
        // Bottom edge
        path.addLine(to: CGPoint(x: cutSize, y: rect.maxY))
        
        // Bottom-left angled corner
        path.addLine(to: CGPoint(x: 0, y: rect.maxY - cutSize))
        
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: cutSize))
        
        // Top-left angled corner (closes the path)
        path.addLine(to: CGPoint(x: cutSize, y: 0))
        
        path.closeSubpath()
        return path
    }
}

#Preview {
    Image("item_border")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 100, height: 100)
    CustomCardShape()
        .stroke(Color.red, lineWidth: 2, antialiased: false)
        .frame(width: 100, height: 100)
}
