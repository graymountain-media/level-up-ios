//
//  LUTipStyle.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/23/25.
//

import SwiftUI
import TipKit

struct LUTipStyle: TipViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            if let title = configuration.title {
                title.font(.headline)
                    .foregroundStyle(Color.orange)
            }
            if let message = configuration.message {
                message.font(.subheadline)
                    .foregroundStyle(.white)
            }
            
            HStack {
                ForEach(configuration.actions, id: \.id) { action in
                    Button {
                        action.handler()
                    } label: {
                        action.label()
                    }
                }
            }
        }
        .padding()
        .background(Color.blue)
    }
}
