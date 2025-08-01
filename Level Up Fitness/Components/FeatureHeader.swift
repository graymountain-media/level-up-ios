//
//  FeatureHeader.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/3/25.
//

import SwiftUI

struct FeatureHeader: View {
    var title: String
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(title.uppercased())
                .font(.mainFont(size: 20).bold())
                .foregroundStyle(Color.title)
            LUDivider()
                .frame(maxWidth: 200)
        }
        .padding(.vertical, 20)
    }
}


#Preview {
    VStack {
        FeatureHeader(title: "Log A Workout")
        Spacer()
    }
    .frame(maxWidth: .infinity)
    .background(Color.major.ignoresSafeArea())
}

