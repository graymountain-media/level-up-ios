//
//  UserInfoPopup.swift
//  Level Up
//
//  Created by Jake Gray on 8/31/25.
//

import SwiftUI
import FactoryKit

struct UserInfoPopup: View {
//    @Injected(\.friendsService) var friendsService
    
    var viewProfile: () -> Void = {}
    var dismiss: () -> Void = {}
    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    withAnimation {
                        dismiss()
                    }
                }
            Rectangle()
                .frame(width: 320, height: 160)
                .transition(.opacity.combined(with: .scale))
        }
    }
}


#Preview {
    UserInfoPopup()
}
