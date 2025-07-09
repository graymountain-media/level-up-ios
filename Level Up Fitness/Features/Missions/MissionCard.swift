import SwiftUI

struct MissionCard: View {
    let mission: Mission
    var isSelected: Bool = false
    let onTap: () -> Void
    let onSelect: () -> Void
    
    init(mission: Mission, isSelected: Bool = false, onTap: @escaping () -> Void, onSelect: @escaping () -> Void) {
        self.mission = mission
        self.isSelected = isSelected
        self.onTap = onTap
        self.onSelect = onSelect
    }
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Image("")
                Text(mission.title)
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(.textOrange)
            }
            .padding()
            .overlay {
                CustomBorderShape()
                    .stroke(Color.border, lineWidth: 1)
                    .padding(5)
                CustomBorderShape(cornerWidth: 13)
                    .stroke(Color.border, lineWidth: 5)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            .background(
                Color.major
                    .clipShape(
                        CustomBorderShape()
                    )
            )
            if isSelected {
                descriptionBody.transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .transition(.opacity)
        
    }
    
    var descriptionBody: some View {
        VStack {
            if mission.status == .inProgress {
                // In Progress Mission View (matching screenshot)
                VStack(spacing: 16) {
                    // Countdown Timer
                    TimeRemainingView(deadline: mission.deadline ?? Date())
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(Color.textOrange)
                    
                    Text("REMAINING")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.textOrange)
                    
                    // Mission Accepted Banner
                    Text("MISSION\nACCEPTED")
                        .font(.system(size: 32, weight: .heavy))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.major)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            Color.textOrange
                                .clipShape(CustomBorderShape())
                                .padding(4)
                        )
                        .overlay {
                            CustomBorderShape(cornerWidth: 13)
                                .stroke(Color.textOrange, lineWidth: 3)
                        }
                        .padding(.horizontal, 40)
                    
                    // Team Up Info
                    VStack(spacing: 4) {
                        Text("TEAM UP WITH PARTY TO")
                            .font(.system(size: 16, weight: .medium))
                        Text("INCREASE SUCCESS CHANCES")
                            .font(.system(size: 16, weight: .medium))
                        Text("5% PER PERSON (MAX 3)")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(Color.white)
                }
                .padding(.vertical, 20)
            } else {
                // Original view for other mission statuses
                VStack(spacing: 20) {
                    // XP Display
                    Text("\(mission.xpReward) XP")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(Color.textOrange)
                    
                    // Mission Details
                    VStack(spacing: 8) {
                        Text("COMPLETION TIME: \(mission.completionTime) HOURS")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.textOrange)
                        
                        Text("SUCCESS RATE: \(mission.successRate)%")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.textOrange)
                    }
                    
                    // Mission Description
                    Text(mission.description)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal)
                    
                    // Select Button
                    Button(action: {
                        onSelect()
                    }) {
                        Image("select_button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 50)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 10)
                }
                .padding(.vertical, 20)
                
            }
        }
        .padding()
        .overlay {
            CustomBorderShape()
                .stroke(Color.border, lineWidth: 4)
                .padding(10)
            CustomBorderShape(cornerWidth: 13)
                .stroke(Color.border, lineWidth: 4)
        }
        .background(
            Color.major
                .clipShape(
                    CustomBorderShape()
                )
        )
    }
    
    private var buttonTitle: String {
        switch mission.status {
        case .available: return "Start"
        case .inProgress: return "In Progress"
        case .completed: return "Claim"
        case .claimed: return "Completed"
        }
    }
    
    private var buttonColor: Color {
        switch mission.status {
        case .available: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        case .claimed: return .gray
        }
    }
    
    private var iconForMission: String {
        if mission.title.lowercased().contains("cardio") {
            return "figure.run"
        } else if mission.title.lowercased().contains("strength") || mission.title.lowercased().contains("weight") {
            return "dumbbell"
        } else if mission.title.lowercased().contains("yoga") {
            return "figure.mind.and.body"
        } else {
            return "flag.checkered"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        MissionCard(
            mission: Mission(
                title: "Daily Cardio Challenge",
                description: "Complete 30 minutes of cardio to earn bonus XP and credits.",
                xpReward: 1300,
                completionTime: 72,
                successRate: 100,
                status: .available,
                levelRequirement: 1
            ),
            onTap: {},
            onSelect: {}
        )
        
        MissionCard(
            mission: Mission(
                title: "Strength Training",
                description: "Complete 3 sets of weight training exercises.",
                xpReward: 200,
                completionTime: 24,
                successRate: 70,
                status: .inProgress,
                levelRequirement: 5
            ),
            onTap: {},
            onSelect: {}
        )
        
        MissionCard(
            mission: Mission(
                title: "Yoga Flow",
                description: "Complete a 20-minute yoga session to improve flexibility.",
                xpReward: 1000,
                completionTime: 48,
                successRate: 85,
                status: .completed,
                levelRequirement: 2
            ),
            onTap: {},
            onSelect: {}
        )
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
