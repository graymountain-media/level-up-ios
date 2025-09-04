//
//  FactionTabs.swift
//  Level Up
//
//  Created by Sam Smith on 9/2/25.
//


enum FactionTabs: String, CaseIterable, Identifiable {
    case overview
    case members
    case strongholds
    
    var id: String { self.rawValue }
    var displayName: String { self.rawValue.capitalized }
}
