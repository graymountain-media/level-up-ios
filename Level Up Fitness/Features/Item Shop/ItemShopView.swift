import SwiftUI

struct ItemShopView: View {
    @State private var selectedCategory: ItemCategory?
    @State private var shopItems: [ShopItem] = []
    @Environment(\.dismiss) private var dismiss
    
    private let dataService = ShopDataService.shared
    
    var filteredItems: [ShopItem] {
        guard let selectedCategory else {
            return shopItems
        }
        return shopItems.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        ZStack {
            Color.major.ignoresSafeArea()
            
            
            VStack(spacing: 0) {
                FeatureHeader(title: "Item Shop")
                categories
                itemList
            }
        }
        .onAppear {
            // Load shop items
            shopItems = dataService.getShopItems()
        }
    }
    
    var categories: some View {
        HStack(spacing: 4) {
            ForEach(ItemCategory.allCases) { category in
                Button(action: {
                    withAnimation {
                        if selectedCategory != category {
                            selectedCategory = category
                        } else {
                            selectedCategory = nil
                        }
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
                }
            }
        }
        .padding(.horizontal)
    }
    
    var itemList: some View {
        let columns: [GridItem] = [.init(.flexible()), .init(.flexible())]
        return ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(filteredItems) { item in
                    ShopItemView(item: item) {
                        // Handle purchase
                        print("Purchased: \(item.name)")
                    }
                }
            }.padding()
        }
        .background(
            Image("citiscape")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .allowsHitTesting(false)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
        
    }
}

#Preview {
    ItemShopView()
}
