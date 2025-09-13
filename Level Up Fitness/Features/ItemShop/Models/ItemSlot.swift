//
//  ItemSlot.swift
//  Level Up
//
//  Created by Jake Gray on 8/8/25.
//


enum ItemSlot: String, CaseIterable, Identifiable, Codable {
    case weapon, helmet, chest
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .weapon: "Weapon"
        case .chest: "Chest"
        case .helmet: "Helmet"
        }
    }
    
    var placeholderImageName: String {
        switch self {
        case .weapon: "weapon_placeholder"
        case .chest: "chestguard_placeholder"
        case .helmet: "helmet_placeholder"
        }
    }
}
