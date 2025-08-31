//
//  FeatureHeader.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/3/25.
//

import SwiftUI

struct FeatureHeader<Right: View>: View {
    @Environment(\.dismiss) private var dismiss
    var title: String
    var showCloseButton: Bool = false
    var right: Right?
    var onDismiss: (() -> Void)? = nil
    
    init(title: String, showCloseButton: Bool = false, @ViewBuilder right: () -> Right, onDismiss: (() -> Void)? = nil) {
        self.title = title
        self.showCloseButton = showCloseButton
        self.right = right()
        self.onDismiss = onDismiss
    }
    
    init(title: String, showCloseButton: Bool = false, onDismiss: (() -> Void)? = nil) where Right == EmptyView {
        self.title = title
        self.showCloseButton = showCloseButton
        self.right = nil
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 12) {
                    Text(title.uppercased())
                        .font(.mainFont(size: 20).bold())
                        .foregroundStyle(Color.title)
                    LUDivider()
                        .frame(maxWidth: 200)
                }
                .padding(.top, 16)
                Spacer()
            }
            HStack {
                if showCloseButton {
                    Button {
                        if let onDismiss {
                            onDismiss()
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.textfieldBorder)
                    }
                    .frame(width: 40, height: 40)
                    Spacer()
                }
                
                if let right {
                    Spacer()
                    right
                }
            }
        }
        .padding(.vertical, 20)
    }
}


#Preview {
    VStack {
        FeatureHeader(title: "Log A Workout", showCloseButton: true)
        Spacer()
    }
    .frame(maxWidth: .infinity)
    .background(Color.major.ignoresSafeArea())
}

