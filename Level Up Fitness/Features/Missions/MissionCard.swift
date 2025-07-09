import SwiftUI

struct MissionCard: View {
    let mission: Mission
    let onAction: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 10) {
            // Left side: Mission icon
            Image("CoreItemIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
            
            // Middle: Mission details
            VStack(alignment: .leading, spacing: 4) {
                // Mission title and XP
                Text(mission.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Mission description
                Text(mission.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 10) {
                Text("Lvl required: \(mission.levelRequirement)")
                Text("Sucess: \(mission.successRate)%")
                Button(action: onAction ?? { }) {
                    Text("Accept Mission")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Capsule().fill(Color.blue))
                        .font(.system(size: 14))
                }
                Text("\(mission.fluxReward) Flux reward")
            }
            .font(.system(size: 12))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .foregroundStyle(Color.white)
        .background(Color.missionCardBG)
        .cornerRadius(12)
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
                fluxReward: 150,
                successRate: 100,
                status: .available,
                levelRequirement: 1
            ),
            onAction: {}
        )
        
        MissionCard(
            mission: Mission(
                title: "Strength Training",
                description: "Complete 3 sets of weight training exercises.",
                fluxReward: 200,
                successRate: 70,
                status: .inProgress,
                levelRequirement: 5
            ),
            onAction: {}
        )
        
        MissionCard(
            mission: Mission(
                title: "Yoga Flow",
                description: "Complete a 20-minute yoga session to improve flexibility.",
                fluxReward: 100,
                successRate: 85,
                status: .completed,
                levelRequirement: 2
            ),
            onAction: {}
        )
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
