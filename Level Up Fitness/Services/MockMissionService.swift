import Foundation

class MockMissionService: MissionServiceProtocol {
    var shouldFail = false
    var mockMissions: [Mission] = Mission.testData
    var mockUserMissions: [UserMission] = [
        UserMission(
            userId: UUID(),
            missionId: Mission.testData.first?.id ?? UUID(),
            completed: false,
            startedAt: Date(),
            finishAt: Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date()
        ),
        UserMission(
            userId: UUID(),
            missionId: Mission.testData[1].id,
            completed: true,
            startedAt: Date(),
            finishAt: Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date()
        ),
        UserMission(
            userId: UUID(),
            missionId: Mission.testData[2].id,
            completed: true,
            startedAt: Date(),
            finishAt: Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date()
        ),
        UserMission(
            userId: UUID(),
            missionId: Mission.testData[3].id,
            completed: true,
            startedAt: Date(),
            finishAt: Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date()
        )
    ]
    
    func fetchAllMissions() async -> Result<[Mission], MissionServiceError> {
        if shouldFail {
            return .failure(.unknownError("Mock fetchAllMissions failed"))
        }
        // Simulate async delay
        try? await Task.sleep(nanoseconds: 200_000_000)
        return .success(mockMissions)
    }
    
    func fetchUserMissions() async -> Result<[UserMission], MissionServiceError> {
        if shouldFail {
            return .failure(.unknownError("Mock fetchUserMissions failed"))
        }
        // Simulate async delay
        try? await Task.sleep(nanoseconds: 200_000_000)
        return .success(mockUserMissions)
    }
    
    func startUserMission(mission: Mission) async -> Result<UserMission, MissionServiceError> {
        if shouldFail {
            return .failure(.unknownError("Mock startUserMission failed"))
        }
        let now = Date()
        let finishAt = Calendar.current.date(byAdding: .hour, value: mission.duration, to: now) ?? now
        let userId = mockUserMissions.first?.userId ?? UUID()
        let userMission = UserMission(
            userId: userId,
            missionId: mission.id,
            completed: false,
            startedAt: now,
            finishAt: finishAt
        )
        mockUserMissions.append(userMission)
        // Simulate async delay
        try? await Task.sleep(nanoseconds: 200_000_000)
        return .success(userMission)
    }
    
    func completeMission(mission: Mission, success: Bool) async -> Result<Void, MissionServiceError> {
        if shouldFail {
            return .failure(.unknownError("Mock completeMission failed"))
        }
        
        if success {
            // Mark mission as completed
            if let index = mockUserMissions.firstIndex(where: { $0.missionId == mission.id }) {
                mockUserMissions[index] = UserMission(
                    userId: mockUserMissions[index].userId,
                    missionId: mockUserMissions[index].missionId,
                    completed: true,
                    startedAt: mockUserMissions[index].startedAt,
                    finishAt: mockUserMissions[index].finishAt
                )
            }
            // In a real app, we'd also update the user's gold here
            print("🏆 Mock: Mission completed successfully! Awarded \(mission.reward) gold.")
        } else {
            // Remove the user mission on failure
            mockUserMissions.removeAll { $0.missionId == mission.id }
            print("❌ Mock: Mission failed. User mission deleted.")
        }
        
        // Simulate async delay
        try? await Task.sleep(nanoseconds: 200_000_000)
        return .success(())
    }
}
