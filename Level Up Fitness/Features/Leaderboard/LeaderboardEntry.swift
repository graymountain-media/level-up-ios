//
//  LeaderboardEntry.swift
//  Level Up
//
//  Created by Jake Gray on 8/25/25.
//

import Foundation

protocol LeaderboardEntry: Identifiable, Decodable, Equatable {
    var userId: UUID { get }
    var value: Int { get }
    var avatarName: String? { get }
    var profilePictureURL: String? { get }
    var heroPath: HeroPath? { get }
    var faction: Faction? { get }
    var level: Int { get }
    var rank: Int { get }
    var id: UUID { get }
}
