import Foundation

struct ShopItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let price: Int
    let xpMultiplier: Double
    let imageName: String
    let category: ItemCategory
    
    let rarity: Rarity
    
    init(id: UUID = UUID(), 
         name: String, 
         description: String, 
         price: Int, 
         xpMultiplier: Double,
         imageName: String, 
         category: ItemCategory, 
         rarity: Rarity) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.xpMultiplier = xpMultiplier
        self.imageName = imageName
        self.category = category
        self.rarity = rarity
    }
}

enum ItemCategory: String, CaseIterable, Identifiable {
    case helmet, armor, gloves, pants, boots, weapon
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .helmet: "Helmet"
        case .armor: "Armor"
        case .gloves: "Gloves"
        case .pants: "Pants"
        case .boots: "Boots"
        case .weapon: "Weapons"
        }
    }
    
    var iconName: String {
        switch self {
        case .helmet:
            "helmet_icon"
        case .armor:
            "armor_icon"
        case .gloves:
            "gloves_icon"
        case .pants:
            "pants_icon"
        case .boots:
            "boots_icon"
        case .weapon:
            "weapon_icon"
        }
    }
}

enum Rarity: String, CaseIterable, Comparable {
    case common, uncommon, rare, epic, legendary
    
    var color: String {
        switch self {
        case .common: return "gray"
        case .uncommon: return "green"
        case .rare: return "blue"
        case .epic: return "purple"
        case .legendary: return "orange"
        }
    }
    
    static func < (lhs: Rarity, rhs: Rarity) -> Bool {
        let order = [common, uncommon, rare, epic, legendary]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}
