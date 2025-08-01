import Foundation

class MockMissionService: MissionServiceProtocol {
    var shouldFail = false
    var mockMissions: [Mission] = Mission.testData
    var mockUserMissions: [UserMission] = [
        UserMission(
            userId: UUID(),
            missionId: Mission.testData.first?.id ?? UUID(),
            completed: true,
            startedAt: Date(),
            completedAt: Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date()
        ),
        UserMission(
            userId: UUID(),
            missionId: Mission.testData.dropFirst().first?.id ?? UUID(),
            completed: true,
            startedAt: Date(),
            completedAt: Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date()
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
}
