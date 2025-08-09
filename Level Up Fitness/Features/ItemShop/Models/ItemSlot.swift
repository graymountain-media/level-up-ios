//
//  ItemSlot.swift
//  Level Up
//
//  Created by Jake Gray on 8/8/25.
//


enum ItemSlot: String, CaseIterable, Identifiable, Codable {
    case weapon, chest, helmet
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .weapon: "Weapon"
        case .chest: "Chest"
        case .helmet: "Helmet"
        }
    }
}
