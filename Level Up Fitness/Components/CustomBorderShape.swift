//
//  CustomBorderShape.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/16/25.
//

import SwiftUI

struct CustomBorderShape: Shape {
    var cornerWidth: CGFloat = 10
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Define the corner size
        let cornerSize = min(cornerWidth, rect.width / 8)
        
        // Start at top left after the corner
        path.move(to: CGPoint(x: rect.minX + cornerSize, y: rect.minY))
        
        // Top edge to top right corner
        path.addLine(to: CGPoint(x: rect.maxX - cornerSize, y: rect.minY))
        
        // Top right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + cornerSize))
        
        // Right edge to bottom right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerSize))
        
        // Bottom right corner
        path.addLine(to: CGPoint(x: rect.maxX - cornerSize, y: rect.maxY))
        
        // Bottom edge to bottom left corner
        path.addLine(to: CGPoint(x: rect.minX + cornerSize, y: rect.maxY))
        
        // Bottom left corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - cornerSize))
        
        // Left edge to top left corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerSize))
        
        // Close the path
        path.closeSubpath()
        
        return path
    }
}
