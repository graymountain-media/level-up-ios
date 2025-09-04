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
        // Use a List or ScrollView to show members.
        // For a full-featured view, you might pass a list of members
        // to this view. For now, it's a simple placeholder.
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
