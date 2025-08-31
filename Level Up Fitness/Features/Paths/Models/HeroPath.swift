//
//  HeroPath.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/8/25.
//

import SwiftUI

// MARK: - HeroPath Model

enum HeroPath: String, CaseIterable, Identifiable, Codable, Equatable {
    case brute = "brute"
    case ranger = "ranger"
    case sentinel = "sentinel"
    case hunter = "hunter"
    case juggernaut = "juggernaut"
    case strider = "strider"
    case champion = "champion"
    
    var id: String {
        self.rawValue
    }
    
    var name: String {
        switch self {
        case .brute:
            return "Brute"
        case .ranger:
            return "Ranger"
        case .sentinel:
            return "Sentinel"
        case .hunter:
            return "Hunter"
        case .juggernaut:
            return "Juggernaut"
        case .strider:
            return "Strider"
        case .champion:
            return "Champion"
        }
    }
    
    var description: String {
        switch self {
        case .brute:
            return "You dominate the battlefield, breaking through defenses and overwhelming anything in your path."
        case .ranger:
            return "You strike fast and vanish faster, wearing down opponents with speed and relentless pursuit."
        case .sentinel:
            return "You hold the line with precision and control, adapting to every threat and staying unshakable under pressure."
        case .hunter:
            return "You combine strength with deadly speed, closing distance fast and delivering crushing blows."
        case .juggernaut:
            return "You're an unstoppable force, blending power and technique to devastate anything that stands before you."
        case .strider:
            return "You move like a shadow across the battlefield, outmaneuvering and outlasting your enemies."
        case .champion:
            return "You are the master of all forms, shifting seamlessly between roles to dominate the fight from every angle."
        }
    }
    
    var iconName: String {
        switch self {
        case .brute:
            return "brute_icon"
        case .ranger:
            return "ranger_icon"
        case .sentinel:
            return "sentinel_icon"
        case .hunter:
            return "hunter_icon"
        case .juggernaut:
            return "juggernaut_icon"
        case .strider:
            return "strider_icon"
        case .champion:
            return "champion_icon"
        }
    }
    
    var primaryWorkoutTypes: [WorkoutType] {
        switch self {
        case .brute:
            return [.strength]
        case .ranger:
            return [.cardio]
        case .sentinel:
            return [.functional]
        case .hunter:
            return [.strength, .cardio]
        case .juggernaut:
            return [.strength, .functional]
        case .strider:
            return [.functional, .cardio]
        case .champion:
            return [.strength, .cardio, .functional]
        }
    }
    
    // Convert database string to Path enum
    static func fromString(_ string: String) -> HeroPath? {
        return HeroPath(rawValue: string.lowercased())
    }
}
