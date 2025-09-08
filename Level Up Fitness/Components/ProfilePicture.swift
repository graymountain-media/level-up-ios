//
//  ProfilePicture.swift
//  Level Up
//
//  Created by Jake Gray on 8/24/25.
//

import SwiftUI

struct ProfilePicture: View {
    let url: String?
    var hasBorder: Bool = false
    var level: Int? = nil
    var body: some View {
        ZStack(alignment: .bottom) {
            CachedAsyncImage(url: URL(string: url ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image("profile_placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                        .frame(width: 55, height: 55)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay {
                            Group {
                                if hasBorder {
                                    RoundedRectangle(cornerRadius: 4)
                                        .strokeBorder(Color.textOrange)
                                }
                            }
                        }
            if let level {
                Text("\(level)")
                    .font(.system(size: 8))
                    .foregroundColor(.white.opacity(0.7))
                    .bold()
                    .padding(.horizontal, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.textfieldBorder)
                            .strokeBorder(Color.majorDark)
                            .frame(height: 15)
                            .frame(minWidth: 15)
                    )
                    .offset(y: 4)
                    
            }
        }
    }
}

#Preview {
    ProfilePicture(url: nil, hasBorder: true, level: 4)
}
