//
//  LoginHeader.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/19/25.
//

import SwiftUI

struct LoginHeader: View {
    var body: some View {
        VStack(spacing: 14) {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Text("Become your own hero".uppercased())
                .font(.mainFont(size: 14))
                .bold()
                .foregroundStyle(.title)
        }
    }
}
