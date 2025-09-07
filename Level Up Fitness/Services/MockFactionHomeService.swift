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
        faction: Faction.echoreach,
        weeklyXP: 12500,
        memberCount: 45,
        topLeaders: [
            Leader(avatarName: "Shadowstrike", avatarImageUrl: "https://placehold.co/128x128/FF5733/ffffff?text=SS", level: 92, xpPoints: 58700),
            Leader(avatarName: "Nightblade", avatarImageUrl: "https://placehold.co/128x128/33C1FF/ffffff?text=NB", level: 88, xpPoints: 55430),
            Leader(avatarName: "Ironclad", avatarImageUrl: "https://placehold.co/128x128/8A33FF/ffffff?text=IC", level: 85, xpPoints: 53110)
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
