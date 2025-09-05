//
//  OtherUsersService.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/31/25.
//

import Foundation
import Supabase

// MARK: - Models

struct OtherUserEquippedItem: Codable {
    let id: UUID
    let userId: UUID
    let itemSlot: String
    let itemId: UUID
    let equippedAt: Date
    let item: OtherUserItem?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case itemSlot = "item_slot"
        case itemId = "item_id"
        case equippedAt = "equipped_at"
        case item
    }
}

struct OtherUserItem: Codable {
    let id: UUID
    let name: String
    let description: String
    let xpBonus: Double
    let price: Int
    let itemSlot: String
    let requiredLevel: Int
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case xpBonus = "xp_bonus"
        case price
        case itemSlot = "item_slot"
        case requiredLevel = "required_level"
    }
    
    var formattedXPBonus: String {
        let xp = String(format: "%.1f", xpBonus)
        return "+\(xp)% XP"
    }
}

// MARK: - Protocol

protocol OtherUsersServiceProtocol {
    func fetchUserProfile(userId: UUID) async throws -> OtherUserProfile
}

class OtherUserProfile: Decodable {
    let id: UUID
    let avatarName: String
    let credits: Int
    let avatarImageUrl: String?
    let profilePictureUrl: String?
    let faction: Faction?
    let heroPath: HeroPath?
    let createdAt: Date
    let currentLevel: Int
    let xp: Int
    let currentStreak: Int
    let longestStreak: Int
    let equippedItemsJson: [String: EquippedItemData]
    
    var progressToNextLevel: Double = 0
    var equippedItems: [OtherUserEquippedItem] = []
    
    private enum CodingKeys: String, CodingKey {
        case id
        case avatarName = "avatar_name"
        case credits
        case avatarImageUrl = "avatar_image_url"
        case profilePictureUrl = "profile_picture_url"
        case faction
        case heroPath = "hero_path"
        case createdAt = "created_at"
        case currentLevel = "current_level"
        case xp
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case equippedItemsJson = "equipped_items"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        avatarName = try container.decode(String.self, forKey: .avatarName)
        credits = try container.decode(Int.self, forKey: .credits)
        avatarImageUrl = try container.decodeIfPresent(String.self, forKey: .avatarImageUrl)
        profilePictureUrl = try container.decodeIfPresent(String.self, forKey: .profilePictureUrl)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        currentLevel = try container.decode(Int.self, forKey: .currentLevel)
        xp = try container.decode(Int.self, forKey: .xp)
        currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        longestStreak = try container.decode(Int.self, forKey: .longestStreak)
        equippedItemsJson = try container.decode([String: EquippedItemData].self, forKey: .equippedItemsJson)
        
        // Custom decoding for enums
        if let factionString = try container.decodeIfPresent(String.self, forKey: .faction) {
            faction = Faction(rawValue: factionString)
        } else {
            faction = nil
        }
        
        if let heroPathString = try container.decodeIfPresent(String.self, forKey: .heroPath) {
            heroPath = HeroPath(rawValue: heroPathString)
        } else {
            heroPath = nil
        }
    }
    
    init(id: UUID = UUID(), avatarName: String, credits: Int = 0, avatarImageUrl: String? = nil, profilePictureUrl: String? = nil, faction: Faction? = nil, heroPath: HeroPath? = nil, createdAt: Date = Date(), currentLevel: Int = 1, xp: Int = 0, currentStreak: Int = 0, longestStreak: Int = 0, equippedItemsJson: [String : EquippedItemData] = [:], progressToNextLevel: Double = 0.0, equippedItems: [OtherUserEquippedItem] = []) {
        self.id = id
        self.avatarName = avatarName
        self.credits = credits
        self.avatarImageUrl = avatarImageUrl
        self.profilePictureUrl = profilePictureUrl
        self.faction = faction
        self.heroPath = heroPath
        self.createdAt = createdAt
        self.currentLevel = currentLevel
        self.xp = xp
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.equippedItemsJson = equippedItemsJson
        self.progressToNextLevel = progressToNextLevel
        self.equippedItems = equippedItems
    }
}

struct EquippedItemData: Codable {
    let itemId: UUID
    let name: String
    let description: String
    let xpBonus: Double
    let equippedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case name
        case description
        case xpBonus = "xp_bonus"
        case equippedAt = "equipped_at"
    }
}

// MARK: - Service Implementation

class OtherUsersService: OtherUsersServiceProtocol {
    
    func fetchUserProfile(userId: UUID) async throws -> OtherUserProfile {
        // Use the new database function to get all data in one call
        let profile: OtherUserProfile = try await client
            .rpc("get_public_user_profile", params: ["target_user_id": userId])
            .single()
            .execute()
            .value
        
        // Get level info for calculations
        let levelInfo: [LevelInfo] = try await client
            .from("level_info")
            .select()
            .order("level", ascending: true)
            .execute()
            .value
        
        // Convert equipped items from JSONB to array format
        let equippedItems = profile.equippedItemsJson.map { (slot, itemData) in
            OtherUserEquippedItem(
                id: itemData.itemId, // Using itemId as id for compatibility
                userId: profile.id,
                itemSlot: slot,
                itemId: itemData.itemId,
                equippedAt: itemData.equippedAt,
                item: OtherUserItem(
                    id: itemData.itemId,
                    name: itemData.name,
                    description: itemData.description,
                    xpBonus: itemData.xpBonus,
                    price: 0, // Not returned by function
                    itemSlot: slot,
                    requiredLevel: 0 // Not returned by function
                )
            )
        }
        
        // Calculate level info
        let userXPInfo = UserXPInfo(xp: profile.xp, currentLevel: profile.currentLevel)
        let currentLevelInfo = OtherUsersService.calculateLevelInfo(xpInfo: userXPInfo, levelInfo: levelInfo)
        
        profile.progressToNextLevel = currentLevelInfo.progressToNextLevel
        profile.equippedItems = equippedItems
        
        return profile
    }
    
    // MARK: - Level Calculation Helpers
    
    /// Calculate level, XP to next level, and progress based on actual level table data
    static func calculateLevelInfo(xpInfo: UserXPInfo, levelInfo: [LevelInfo]) -> (xpToNextLevel: Int, progressToNextLevel: Double) {
        
        guard let currentLevelInfo = levelInfo.first(where: { $0.level == xpInfo.currentLevel + 1 }) else {
            return (0,0.0)
        }
        
        let xpToNextLevel = currentLevelInfo.cumulativeXP - xpInfo.xp
        let interval = currentLevelInfo.xpToReach
        let intervalProgress = Double(interval - xpToNextLevel) / Double(interval)
        return (xpToNextLevel, intervalProgress)
    }
}

// MARK: - Mock Service

class MockOtherUsersService: OtherUsersServiceProtocol {
    func fetchUserProfile(userId: UUID) async throws -> OtherUserProfile {
        // Mock equipped items data
        let mockEquippedItemData = EquippedItemData(
            itemId: UUID(),
            name: "Test Weapon",
            description: "A test weapon",
            xpBonus: 1.5,
            equippedAt: Date()
        )
        
        let mockEquippedItems = ["weapon": mockEquippedItemData]
        
        // Create mock profile directly with new structure
        let mockProfile = OtherUserProfile(
            id: userId,
            avatarName: "AVARII",
            credits: 100,
            avatarImageUrl: nil,
            profilePictureUrl: nil,
            faction: .pulseforge,
            heroPath: .ranger,
            createdAt: Date(),
            currentLevel: 7,
            xp: 1500,
            currentStreak: 5,
            longestStreak: 10,
            equippedItemsJson: mockEquippedItems,
            progressToNextLevel: 0.75,
            equippedItems: []
        )
        
        // Convert equipped items to array format (simulating what the real service does)
        let equippedItemsArray = mockEquippedItems.map { (slot, itemData) in
            OtherUserEquippedItem(
                id: itemData.itemId,
                userId: userId,
                itemSlot: slot,
                itemId: itemData.itemId,
                equippedAt: itemData.equippedAt,
                item: OtherUserItem(
                    id: itemData.itemId,
                    name: itemData.name,
                    description: itemData.description,
                    xpBonus: itemData.xpBonus,
                    price: 100,
                    itemSlot: slot,
                    requiredLevel: 1
                )
            )
        }
        
        mockProfile.equippedItems = equippedItemsArray
        
        return mockProfile
    }
}
