//
//  InventoryView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/4/25.
//

import SwiftUI

// MARK: - Models
struct InventoryItem: Identifiable {
    let id = UUID()
    let name: String
    let category: ItemCategory
    let imageName: String
    let isEquipped: Bool
    let isLocked: Bool
}

struct InventoryView: View {
    // MARK: - Properties
    @State private var selectedCategory: ItemCategory? = nil
    @State private var inventoryItems: [InventoryItem] = [
        // Helmet items
        InventoryItem(name: "Basic Helmet", category: .armor, imageName: "armor", isEquipped: false, isLocked: false),
    ]
    
    // MARK: - Computed Properties
    private var filteredItems: [InventoryItem] {
        return inventoryItems
//        inventoryItems.filter { $0.category == selectedCategory }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            Color.major
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Close button and header
                    FeatureHeader(title: "Inventory")
                    
                    // Main content
                    HStack(alignment: .top, spacing: 16) {
                        // Category sidebar
                        categorySidebar
                        itemGrid
                    }
                    .padding(.horizontal, 16)
                    characterPreview
                }
                .padding(.top, 16)
            }
        }
    }
    
    // MARK: - Category Sidebar
    private var categorySidebar: some View {
        VStack(spacing: 4) {
            ForEach(ItemCategory.allCases) { category in
                Button(action: {
                    withAnimation {
                        selectedCategory = category
                    }
                }) {
                    Image(category.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(4)
                        .background {
                            if category == selectedCategory {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.minor)
                            }
                        }
                        .frame(maxHeight: 70)
                }
            }
        }
    }
    
    // MARK: - Item Grid
    private var itemGrid: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.minor.opacity(0.4))
            
            // Grid layout
            HStack {
                VStack(spacing: 16) {
                    ForEach(filteredItems) { item in
                        itemCell(item: item)
                    }
                    if filteredItems.count < 5 {
                        ForEach(1...(5 - filteredItems.count), id: \.self) { _ in
                            emptyItemCell()
                        }
                    }
                }
                .padding(16)
                Spacer()
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Item Cell
    private func itemCell(item: InventoryItem) -> some View {
        Button(action: {
            // Item selection action would go here
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
            }
            
        }
        .frame(maxWidth: 60, maxHeight: 60)
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func emptyItemCell() -> some View {
        Button(action: {
            // Item selection action would go here
        }) {
            Image("empty_armor")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
        }
        .frame(maxWidth: 60, maxHeight: 60)
        .aspectRatio(1, contentMode: .fit)
    }
    
    // MARK: - Character Preview
    private var characterPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.minor.opacity(0.4))
            
            // Character silhouette with geometric pattern overlay
            Image("william_vengence")
                .resizable()
                .scaledToFit()
                .padding(.top, 16)
        }
        .padding(.horizontal)
    }
}

#Preview {
    InventoryView()
}
