//
//  FactionStrongholdsView.swift
//  Level Up
//
//  Created by Sam Smith on 9/3/25.
//

import SwiftUI

struct FactionStrongholdsView: View {
    let faction: FactionDetails? = nil

    var body: some View {
        VStack {
            Text("Strongholds Map")
                .font(.largeTitle)
                .padding()
            
            Text("Showing strongholds for \(faction?.name ?? "Name").")
                .font(.headline)
            
            Spacer()
        }
    }
}

#Preview {
    FactionStrongholdsView()
}
