//
//  Item.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/8/25.
//

import Foundation

// MARK: - Item Models

struct Item: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let xpBonus: Double
    let price: Int
    let itemSlot: ItemSlot
    let requiredPaths: [HeroPath]
    let requiredLevel: Int
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case xpBonus = "xp_bonus"
        case price
        case itemSlot = "item_slot"
        case requiredPaths = "required_paths"
        case requiredLevel = "required_level"
    }
    
    /// Check if this item can be used by the given hero path
    func isCompatibleWith(path: HeroPath?) -> Bool {
        // If no path requirements, item is available to everyone (recruit items)
        guard !requiredPaths.isEmpty else { return true }
        
        // Check if user's path is in the required paths
        guard let userPath = path else { return false }
        return requiredPaths.contains(userPath)
    }
    
    /// Check if user meets the level requirement for this item
    func meetsLevelRequirement(userLevel: Int) -> Bool {
        return userLevel >= requiredLevel
    }
    
    /// Get the formatted price string
    var formattedPrice: String {
        return "\(price) gold"
    }
    
    var shortXP: String {
        let xp = String(format: "%.1f", xpBonus)
        return "\(xp)%"
    }
    /// Get the formatted XP bonus string
    var formattedXPBonus: String {
        let xp = String(format: "%.1f", xpBonus)
        return "+\(xp)% XP"
    }
    
    var imageName: String? {
        return self.name
    }
}

// MARK: - User Item Models

struct UserItem: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let itemId: UUID
    let purchasedAt: Date
    let quantity: Int
    
    // Associated item data (from join)
    var item: Item?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case itemId = "item_id"
        case purchasedAt = "purchased_at"
        case quantity
    }
}

struct UserEquippedItem: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let itemSlot: ItemSlot
    let itemId: UUID
    let equippedAt: Date
    
    // Associated item data (from join)
    var item: Item?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case itemSlot = "item_slot"
        case itemId = "item_id"
        case equippedAt = "equipped_at"
    }
}

// MARK: - User Inventory

struct UserInventory {
    let ownedItems: [UserItem]
    let equippedItems: [UserEquippedItem]
    
    /// Get all items the user owns
    var allItems: [Item] {
        return ownedItems.compactMap { $0.item }
    }
    
    /// Get equipped item for a specific slot
    func equippedItem(for slot: ItemSlot) -> UserEquippedItem? {
        return equippedItems.first { $0.itemSlot == slot }
    }
    
    /// Check if user owns a specific item
    func owns(itemId: UUID) -> Bool {
        return ownedItems.contains { $0.itemId == itemId }
    }
    
    /// Check if an item is currently equipped
    func isEquipped(itemId: UUID) -> Bool {
        return equippedItems.contains { $0.itemId == itemId }
    }
    
    /// Get total XP bonus from all equipped items
    var totalXPBonus: Double {
        return equippedItems.compactMap { $0.item?.xpBonus }.reduce(0, +)
    }
}
