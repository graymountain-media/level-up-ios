//
//  LUTextField.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/2/25.
//

import SwiftUI
import Combine

struct LUTextField: View {
    let title: String
    var detail: String?
    @Binding var text: String
    var placeholder: String?
    var isSecure: Bool = false
    var maxLength: Int?
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .bottom) {
                Text(title)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(Color.textDetail)
                Spacer()
                if let detail {
                    Text(detail)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.textDetail)
                }
            }
            
            textField
                .tint(.white)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .frame(height: 46)
                
                .background(RoundedRectangle(cornerRadius: 8).fill(.textfieldBg))
                .overlay (
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.textfieldBorder, lineWidth: 1)
                )
                .padding(.bottom, 8) // Add some padding at the bottom for visual balance
        }
    }
    
    @ViewBuilder
    private var textField: some View {
        if isSecure {
            SecureField(placeholder ?? "", text: $text, prompt: Text(placeholder ?? "").foregroundStyle(.white.opacity(0.5)))
        } else {
            TextField(placeholder ?? "", text: $text, prompt: Text(placeholder ?? "").foregroundStyle(.white.opacity(0.5))
            )
            .onReceive(Just(text)) { _ in limitText(maxLength) }
                
        }
    }
    
    private func limitText(_ upper: Int?) {
        guard let upper else { return }
        if text.count > upper {
            text = String(text.prefix(upper))
        }
    }
}

struct TextFieldPreviewView: View {
    @State var username: String = ""
    @FocusState var focusState: Field?
    
    enum Field: Int, Hashable {
        case username = 0
    }
    
    var body: some View {
        ZStack {
            Color.major.ignoresSafeArea()
            LUTextField(title: "Username", detail: "\(username.count)/16", text: $username, placeholder: "John Doe", maxLength: 16)
                .padding()
        }
    }
}
#Preview {
    TextFieldPreviewView()
}
