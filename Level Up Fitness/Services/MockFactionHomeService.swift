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
            Leader(avatarName: "Shadowstrike", profilePictureUrl: "https://placehold.co/128x128/FF5733/ffffff?text=SS", level: 92, xpPoints: 58700),
            Leader(avatarName: "Nightblade", profilePictureUrl: "https://placehold.co/128x128/33C1FF/ffffff?text=NB", level: 88, xpPoints: 55430),
            Leader(avatarName: "Ironclad", profilePictureUrl: "https://placehold.co/128x128/8A33FF/ffffff?text=IC", level: 85, xpPoints: 53110)
        ]
    )
    
    private let mockFactionMembers: [FactionMember] = [
        FactionMember(
                id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!,
                avatarName: "Phoenix",
                profilePictureUrl: "https://placehold.co/128x128/FF5733/ffffff?text=L1",
                level: 35,
                xpPoints: 50000,
                heroPath: HeroPath.brute
            ),
            FactionMember(
                id: UUID(uuidString: "423e4567-e89b-12d3-a456-426614174001")!,
                avatarName: "Seraphina",
                profilePictureUrl: "https://placehold.co/128x128/33FF57/ffffff?text=L2",
                level: 30,
                xpPoints: 45000,
                heroPath: HeroPath.champion
            ),
            FactionMember(
                id: UUID(uuidString: "723e4567-e89b-12d3-a456-426614174002")!,
                avatarName: "Triton",
                profilePictureUrl: "https://placehold.co/128x128/33A2FF/ffffff?text=L3",
                level: 28,
                xpPoints: 42000,
                heroPath: HeroPath.hunter
            ),
            FactionMember(
                id: UUID(uuidString: "a23e4567-e89b-12d3-a456-426614174003")!,
                avatarName: "Nyx",
                profilePictureUrl: "https://placehold.co/128x128/9933FF/ffffff?text=L4",
                level: 25,
                xpPoints: 38000,
                heroPath: HeroPath.ranger
            )
    ]
    
    init() {
        setupMockData()
    }
    
    private func setupMockData() {}
    
    // MARK: - Protocol Implementation
    
    func fetchFactionDetails() async -> Result<FactionDetails, FactionHomeError> {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        return .success(mockFactionDetails)
    }
    
    func getFactionMembers() async -> Result<[FactionMember], FactionHomeError> {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        return .success(mockFactionMembers)
    }
}
