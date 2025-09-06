//
//  MockFactionHomeService.swift
//  Level Up
//
//  Created by Sam Smith on 9/3/25.
//

import Foundation

class MockFactionHomeService: FactionHomeServiceProtocol {
    
    // Mock data storage
    private var mockFactionDetails: FactionDetails = FactionDetails(
        factionId: UUID(uuidString: "7a1b9c4d-2e6f-4a8b-9e1c-3d5f7a9c2b8d")!,
        factionType: Faction.echoreach,
        name: "The Iron Guardians",
        iconName: "faction_iron_guard",
        description: "A faction forged in the fires of conflict, dedicated to protecting the innocent and upholding justice. Their members are known for their resilience and steadfast resolve in the face of adversity.",
        weeklyXP: 58742,
        memberCount: 345,
        levelLine: 165,
        topLeaders: [
            Leader(rank: "Faction Leader", name: "WALLYG", avatarName: "avatar_wallyg", level: 9, points: 2080),
            Leader(rank: "1st Officer", name: "EMBER", avatarName: "avatar_ember", level: 6, points: 900),
            Leader(rank: "2nd Officer", name: "NYX", avatarName: "avatar_nyx", level: 5, points: 540)
        ]
    )
    
    init() {
        setupMockData()
    }
    
    private func setupMockData() {}
    
    // MARK: - Protocol Implementation
    
    func fetchFactionDetails() async -> Result<FactionDetails, FactionHomeError> {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        return .success(mockFactionDetails)
    }
}
