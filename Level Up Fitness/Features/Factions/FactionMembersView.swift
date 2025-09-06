//
//  FactionMembersView.swift
//  Level Up
//
//  Created by Sam Smith on 9/3/25.
//

import SwiftUI

struct FactionMembersView: View {
    let faction: FactionDetails? = nil
    
    var body: some View {
        // TODO: Do in another PR
        VStack {
            Text("Members List")
                .font(.largeTitle)
                .padding()
            
            Text("Number of members: \(faction?.memberCount ?? 0)")
                .font(.headline)
            
            Spacer()
        }
    }
}

#Preview {
    FactionMembersView()
}
