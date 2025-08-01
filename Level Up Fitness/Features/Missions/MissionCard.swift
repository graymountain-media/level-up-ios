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
        VStack {
            HStack(alignment: .center, spacing: 16) {
                // Mission image
                Image(mission.title)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.textfieldBorder, lineWidth: 1)
                    )
                VStack(alignment: .leading, spacing: 4) {
                    Text(mission.title.uppercased())
                        .font(.mainFont(size: 17.5))
                        .bold()
                        .foregroundColor(.textOrange)
                    HStack(alignment: .top, spacing: 4) {
                        if !isSelected {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Level Required: \(mission.levelRequirement)")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.textDetail)
                                Text("Duration: \(mission.duration)h")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.textDetail)
                            }
                            
                            Spacer()
                        }
                        Text("Reward: \(mission.reward)")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.white)
                        Image("gold_icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                        if isSelected {
                            Spacer()
                        }
                        
                    }
                    Spacer(minLength: 0)
                }
                .frame(height: 56)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            if isSelected {
                descriptionBody
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.textfieldBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.textfieldBorder, lineWidth: 1)
                )
        )
    }
    
    var descriptionBody: some View {
        VStack {
            VStack(spacing: 12) {
                Text(mission.description)
                    .font(.system(size: 13))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.textDetail)
                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Level Required: \(mission.levelRequirement)")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.white)
                        Text("Duration: \(mission.duration)h")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.white)
                    }
                    Spacer(minLength: 0)
                    VStack {
                        HStack(spacing: 2) {
                            Text("Success Chance: ")
                                .font(.system(size: 13))
                                .foregroundStyle(.white)
                            Text("\(mission.successChances.display ?? 50)%")
                                .font(.system(size: 13))
                                .foregroundStyle(.green)
                        }
                        Button("Start Mission") {
                            
                        }
                        .foregroundStyle(.black)
                        .font(Font.mainFont(size: 17.5))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .padding(.top, 2)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(
                                        LinearGradient(colors: [.textOrange, .goldDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.major, lineWidth: 1.1)
                                    .padding(2)
                            }
                        )
                        .padding(1)
                        .drawingGroup()
//                        .opacity(isEnabled ? 1 : 0.5)
//                        .overlay {
//                            if isLoading {
//                                ProgressView()
//                                    .progressViewStyle(.circular)
//                                    .tint(.major)
//                            }
//                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
//            if mission.status == .inProgress {
//                // In Progress Mission View (matching screenshot)
//                VStack(spacing: 16) {
//                    // Countdown Timer
//                    TimeRemainingView(deadline: mission.deadline ?? Date())
//                        .font(.system(size: 48, weight: .bold))
//                        .foregroundStyle(Color.textOrange)
//                    
//                    Text("REMAINING")
//                        .font(.system(size: 24, weight: .bold))
//                        .foregroundStyle(Color.textOrange)
//                    
//                    // Mission Accepted Banner
//                    Text("MISSION\nACCEPTED")
//                        .font(.system(size: 32, weight: .heavy))
//                        .multilineTextAlignment(.center)
//                        .foregroundStyle(Color.major)
//                        .padding(.vertical, 12)
//                        .frame(maxWidth: .infinity)
//                        .background(
//                            Color.textOrange
//                                .clipShape(CustomBorderShape())
//                                .padding(4)
//                        )
//                        .overlay {
//                            CustomBorderShape(cornerWidth: 13)
//                                .stroke(Color.textOrange, lineWidth: 3)
//                        }
//                        .padding(.horizontal, 40)
//                    
//                    // Team Up Info
//                    VStack(spacing: 4) {
//                        Text("TEAM UP WITH PARTY TO")
//                            .font(.system(size: 16, weight: .medium))
//                        Text("INCREASE SUCCESS CHANCES")
//                            .font(.system(size: 16, weight: .medium))
//                        Text("5% PER PERSON (MAX 3)")
//                            .font(.system(size: 14, weight: .medium))
//                    }
//                    .foregroundStyle(Color.white)
//                }
//                .padding(.vertical, 20)
//            } else {
//                // Original view for other mission statuses
//                VStack(spacing: 20) {
//                    // XP Display
//                    Text("\(mission.xpReward) XP")
//                        .font(.system(size: 48, weight: .bold))
//                        .foregroundStyle(Color.textOrange)
//                    
//                    // Mission Details
//                    VStack(spacing: 8) {
//                        Text("COMPLETION TIME: \(mission.completionTime) HOURS")
//                            .font(.system(size: 16, weight: .medium))
//                            .foregroundStyle(Color.textOrange)
//                        
//                        Text("SUCCESS RATE: \(mission.successRate)%")
//                            .font(.system(size: 16, weight: .medium))
//                            .foregroundStyle(Color.textOrange)
//                    }
//                    
//                    // Mission Description
//                    Text(mission.description)
//                        .font(.system(size: 16))
//                        .multilineTextAlignment(.center)
//                        .foregroundStyle(Color.white)
//                        .padding(.horizontal)
//                    
//                    // Select Button
//                    Button(action: {
//                        onSelect()
//                    }) {
//                        Image("select_button")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(height: 50)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                    .padding(.top, 10)
//                }
//                .padding(.vertical, 20)
//                
//            }
        }
    }
    
    private var buttonTitle: String {
        return "Start"
//        switch mission.status {
//        case .available: return "Start"
//        case .inProgress: return "In Progress"
//        case .completed: return "Claim"
//        case .claimed: return "Completed"
//        }
    }
    
    private var buttonColor: Color {
        return .blue
//        switch mission.status {
//        case .available: return .blue
//        case .inProgress: return .orange
//        case .completed: return .green
//        case .claimed: return .gray
//        }
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
        ForEach(Mission.testData) { mission in
            MissionCard(
                mission: mission,
                isSelected: true,
                onTap: {},
                onSelect: {}
            )
        }
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
