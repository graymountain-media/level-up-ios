//
//  AvatarBaseView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/4/25.
//

import SwiftUI

struct AvatarBaseView: View {
    var body: some View {
        VStack {
            Spacer()
            Image("william_vengence")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(y: 40)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                Color.black.ignoresSafeArea()
                    .allowsHitTesting(false)
                Image("citiscape")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
    }
}
