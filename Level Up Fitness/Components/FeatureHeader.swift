//
//  FeatureHeader.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/3/25.
//

import SwiftUI

struct FeatureHeader: View {
    @Environment(\.dismiss) var dismiss
    var titleImageName: String
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack {
                Spacer()
                
                Image(titleImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
                
                Spacer()
            }
            .padding(.bottom, 24)
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                    .padding(.horizontal, 24)
                    .foregroundStyle(Color.minor)
            }
            
        }
    }
}
