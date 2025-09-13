//
//  ItemSlotView.swift
//  Level Up
//
//  Created by Jake Gray on 8/8/25.
//

import SwiftUI

struct ItemSlotView: View {
    let itemSlot: ItemSlot
    let item: Item?
    var body: some View {
        ZStack {
            VStack {
                if let imageName = item?.imageName {
                    Image(imageName)
                        .resizable()
                } else {
                    Image(itemSlot.placeholderImageName)
                        .resizable()
                }
            }
            .clipShape(CustomCardShape())
            .padding(.vertical, 1)
            Image("item_border")
                .resizable()
        }
        .aspectRatio(contentMode: .fit)
    }
}
