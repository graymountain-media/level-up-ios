//
//  FeatureHeader.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/3/25.
//

import SwiftUI

struct FeatureHeader: View {
    @Environment(\.dismiss) var dismiss
    var title: String
    var showCloseButton: Bool = false
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
                Spacer()
            }
            if showCloseButton {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.textfieldBorder)
                }
                .frame(width: 40, height: 40)
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

