//
//  ItemService.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/8/25.
//

import Foundation
import Supabase

enum ItemServiceError: LocalizedError {
    case notAuthenticated
    case itemNotFound
    case insufficientCredits
    case itemAlreadyOwned
    case itemNotOwned
    case pathRequirementNotMet
    case databaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to purchase items"
        case .itemNotFound:
            return "Item not found"
        case .insufficientCredits:
            return "Insufficient credits to purchase this item"
        case .itemAlreadyOwned:
            return "You already own this item"
        case .itemNotOwned:
            return "You don't own this item"
        case .pathRequirementNotMet:
            return "Your hero path cannot use this item"
        case .databaseError(let message):
            return "Database error: \(message)"
        }
    }
}

protocol ItemServiceProtocol {
    func fetchAllItems() async throws -> [Item]
    func fetchUserInventory() async throws -> UserInventory
    func purchaseItem(_ itemId: UUID) async throws -> Void
    func equipItem(_ itemId: UUID) async throws -> Void
    func unequipItem(slot: ItemSlot) async throws -> Void
}

@MainActor
class ItemService: ItemServiceProtocol {
    
    // MARK: - Fetch Items
    
    func fetchAllItems() async throws -> [Item] {
        let items: [Item] = try await client
            .from("items")
            .select()
            .order("price", ascending: true)
            .execute()
            .value
        
        return items
    }
    
    func fetchUserInventory() async throws -> UserInventory {
        let userId = try await client.auth.session.user.id
        
        // Fetch owned items (simple query)
        let ownedItems: [UserItem] = try await client
            .from("user_items")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        // Fetch equipped items (simple query)
        let equippedItems: [UserEquippedItem] = try await client
            .from("user_equipped_items")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        // Get all unique item IDs we need to fetch
        let allItemIds = Set(ownedItems.map { $0.itemId } + equippedItems.map { $0.itemId })
        
        // Fetch all items in one query
        let items: [Item] = try await client
            .from("items")
            .select()
            .in("id", values: Array(allItemIds))
            .execute()
            .value
        
        // Create lookup dictionary for items
        let itemsDict = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        
        // Attach items to owned items
        let ownedItemsWithItems = ownedItems.map { userItem in
            var item = userItem
            item.item = itemsDict[userItem.itemId]
            return item
        }
        
        // Attach items to equipped items
        let equippedItemsWithItems = equippedItems.map { equippedItem in
            var item = equippedItem
            item.item = itemsDict[equippedItem.itemId]
            return item
        }
        
        return UserInventory(ownedItems: ownedItemsWithItems, equippedItems: equippedItemsWithItems)
    }
    
    // MARK: - Item Operations
    
    func purchaseItem(_ itemId: UUID) async throws {
        let userId = try await client.auth.session.user.id
        
        // Get item details
        let item: Item = try await client
            .from("items")
            .select()
            .eq("id", value: itemId)
            .single()
            .execute()
            .value
        
        // Check if user already owns the item
        let existingItem: [UserItem] = try await client
            .from("user_items")
            .select()
            .eq("user_id", value: userId)
            .eq("item_id", value: itemId)
            .execute()
            .value
        
        if !existingItem.isEmpty {
            throw ItemServiceError.itemAlreadyOwned
        }
        
        // Get user's current credits and path
        let profile: Profile = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        
        // Check if user has enough credits
        if profile.credits < item.price {
            throw ItemServiceError.insufficientCredits
        }
        
        // Check if user's path can use this item
        if !item.isCompatibleWith(path: profile.path) {
            throw ItemServiceError.pathRequirementNotMet
        }
        let params: [String: AnyJSON] = [
            "user_id_param": .string(userId.uuidString),
            "item_id_param": .string(itemId.uuidString),
            "item_price": .integer(item.price)
        ]
        // Perform transaction: deduct credits and add item
        try await client.rpc("purchase_item", params: params).execute()
    }
    
    func equipItem(_ itemId: UUID) async throws {
        let userId = try await client.auth.session.user.id
        
        // Verify user owns the item
        let userItems: [UserItem] = try await client
            .from("user_items")
            .select()
            .eq("user_id", value: userId)
            .eq("item_id", value: itemId)
            .execute()
            .value
        
        guard !userItems.isEmpty else {
            throw ItemServiceError.itemNotOwned
        }
        
        // Get item details to know the slot
        let item: Item = try await client
            .from("items")
            .select()
            .eq("id", value: itemId)
            .single()
            .execute()
            .value
        
        // Use database function to handle equipping logic
        let params: [String: AnyJSON] = [
            "user_id_param": .string(userId.uuidString),
            "item_id_param": .string(itemId.uuidString),
            "item_slot_param": .string(item.itemSlot.rawValue)
        ]
        
        try await client.rpc("equip_item", params: params).execute()
    }
    
    func unequipItem(slot: ItemSlot) async throws {
        let userId = try await client.auth.session.user.id
        
        try await client
            .from("user_equipped_items")
            .delete()
            .eq("user_id", value: userId)
            .eq("item_slot", value: slot.rawValue)
            .execute()
    }
}

// MARK: - Mock Service

#if DEBUG
class MockItemService: ItemServiceProtocol {
    private let mockItems: [Item] = [
        Item(
            id: UUID(),
            name: "Training Pistol",
            description: "A lightweight sidearm designed for recruits. Its energy output is low and is only capable of stunning.",
            xpBonus: 1.5,
            price: 20,
            itemSlot: .weapon,
            requiredPaths: []
        ),
        Item(
            id: UUID(),
            name: "Ion Handgun",
            description: "A compact firearm capable of disrupting light armor and electronic shielding. Favored by scouts and infiltration units.",
            xpBonus: 4.5,
            price: 84,
            itemSlot: .weapon,
            requiredPaths: [.ranger, .hunter, .strider]
        )
    ]
    
    private var userOwnedItems: [UUID] = []
    private var userEquippedItems: [ItemSlot: UUID] = [:]
    
    func fetchAllItems() async throws -> [Item] {
        return mockItems
    }
    
    func fetchUserInventory() async throws -> UserInventory {
        let ownedItems = userOwnedItems.compactMap { itemId -> UserItem? in
            guard let item = mockItems.first(where: { $0.id == itemId }) else { return nil }
            var userItem = UserItem(
                id: UUID(),
                userId: UUID(),
                itemId: itemId,
                purchasedAt: Date(),
                quantity: 1
            )
            userItem.item = item
            return userItem
        }
        
        let equippedItems = userEquippedItems.compactMap { (slot, itemId) -> UserEquippedItem? in
            guard let item = mockItems.first(where: { $0.id == itemId }) else { return nil }
            var equippedItem = UserEquippedItem(
                id: UUID(),
                userId: UUID(),
                itemSlot: slot,
                itemId: itemId,
                equippedAt: Date()
            )
            equippedItem.item = item
            return equippedItem
        }
        
        return UserInventory(ownedItems: ownedItems, equippedItems: equippedItems)
    }
    
    func purchaseItem(_ itemId: UUID) async throws {
        userOwnedItems.append(itemId)
    }
    
    func equipItem(_ itemId: UUID) async throws {
        guard let item = mockItems.first(where: { $0.id == itemId }) else { return }
        userEquippedItems[item.itemSlot] = itemId
    }
    
    func unequipItem(slot: ItemSlot) async throws {
        userEquippedItems.removeValue(forKey: slot)
    }
}
#endif
