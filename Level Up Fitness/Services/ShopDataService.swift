import Foundation

class ShopDataService {
    static let shared = ShopDataService()
    
    private init() {}
    
    func getShopItems() -> [ShopItem] {
        return [
            ShopItem(
                name: "Silver Boots",
                description: "Those are some pretty boots.",
                price: 100,
                xpMultiplier: 0.05,
                imageName: "silver_boots",
                category: .boots,
                rarity: .uncommon
            ),
            ShopItem(
                name: "Brown Boots",
                description: "Sturdy boots for any adventurer.",
                price: 300,
                xpMultiplier: 0.15,
                imageName: "brown_boots",
                category: .boots,
                rarity: .uncommon
            ),
            
        ]
    }
    
    func getShopItems(byCategory category: ItemCategory) -> [ShopItem] {
        return getShopItems().filter { $0.category == category }
    }
}
