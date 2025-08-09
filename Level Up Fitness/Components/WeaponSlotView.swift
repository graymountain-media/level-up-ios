//
//  WeaponSlotView.swift
//  Level Up
//
//  Created by Jake Gray on 8/8/25.
//

import SwiftUI

struct WeaponSlotView: View {
    let item: Item?
    var body: some View {
        ZStack {
            if let imageName = item?.imageName {
                Image(imageName)
                    .resizable()
                Image("item_border")
                    .resizable()
            } else {
                Image("item_weapon_placeholder")
                    .resizable()
            }
                
            
        }
        .aspectRatio(contentMode: .fit)
    }
}
