//
//  ProfilePicture.swift
//  Level Up
//
//  Created by Jake Gray on 8/24/25.
//

import SwiftUI

struct ProfilePicture: View {
    let url: String?
    var body: some View {
        CachedAsyncImage(url: URL(string: url ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image("profile_placeholder")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .frame(width: 52, height: 52)
    }
}
