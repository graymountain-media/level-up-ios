//
//  LUTextField.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/2/25.
//

import SwiftUI

// MARK: - Custom Border Shape
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

struct LUTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool
    
    // Customization properties
    var borderColor: Color = .border
    var borderWidth: CGFloat = 2
    var cornerWidth: CGFloat = 10
    var height: CGFloat = 50
    
    init(_ placeholder: String, text: Binding<String>, isSecure: Bool = false) {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(placeholder.uppercased())
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.textOrange)
                    .shadow(radius: 1)
                Spacer()
            }
            
            textField
                .tint(.white)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .frame(height: height)
                .overlay (
                    CustomBorderShape(cornerWidth: cornerWidth)
                        .stroke(borderColor, lineWidth: borderWidth)
                        .borderShadow()
                )
                .padding(.bottom, 8) // Add some padding at the bottom for visual balance
        }
    }
    
    var textField: some View {
        Group {
            if isSecure {
                SecureField("", text: $text)
            } else {
                TextField("", text: $text)
            }
        }
    }
}

// MARK: - Modifiers
extension LUTextField {
    func withBorderStyle(color: Color, width: CGFloat = 2, cornerWidth: CGFloat = 20) -> LUTextField {
        var textField = self
        textField.borderColor = color
        textField.borderWidth = width
        textField.cornerWidth = cornerWidth
        return textField
    }
    
    func withHeight(_ height: CGFloat) -> LUTextField {
        var textField = self
        textField.height = height
        return textField
    }
}

#Preview {
    VStack(spacing: 20) {
        LUTextField("Username", text: .constant("player1"))
        LUTextField("Password", text: .constant("secret"), isSecure: true)
            .withBorderStyle(color: .blue, width: 2.5)
        LUTextField("Email", text: .constant("example@email.com"))
            .withHeight(60)
    }
    .padding()
    .background(Color.black)
}
