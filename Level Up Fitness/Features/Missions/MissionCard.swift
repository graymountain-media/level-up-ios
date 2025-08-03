import SwiftUI
import FactoryKit

struct MissionCard: View {
    let mission: Mission
    var isSelected: Bool = false
    var isLoading: Bool
    var isActiveMission: Bool = false
    var isCompletedMission: Bool = false
    let onTap: () -> Void
    let onSelect: () -> Void
    let onComplete: () -> Void
    
    @InjectedObservable(\.missionManager) var missionManager
    @State private var timerText: String = ""
    
    init(mission: Mission, isSelected: Bool = false, isLoading: Bool, isActiveMission: Bool = false, isCompletedMission: Bool = false, onTap: @escaping () -> Void, onSelect: @escaping () -> Void, onComplete: @escaping () -> Void) {
        self.mission = mission
        self.isSelected = isSelected
        self.isLoading = isLoading
        self.isActiveMission = isActiveMission
        self.isCompletedMission = isCompletedMission
        self.onTap = onTap
        self.onSelect = onSelect
        self.onComplete = onComplete
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 16) {
                // Mission image
                Image(mission.title.filter { !$0.isPunctuation })
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
                        .minimumScaleFactor(0.5)
                        .bold()
                        .foregroundColor(.textOrange)
                    HStack(alignment: .top, spacing: 4) {
                        if !isSelected {
                            if isActiveMission {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Time Remaining:")
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.textDetail)
                                    Text(timerText)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.textDetail)
                                }
                            } else {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Level Required: \(mission.levelRequirement)")
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.textDetail)
                                    Text("Duration: \(mission.duration)h")
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.textDetail)
                                }
                            }
                            
                            Spacer()
                        }
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 4) {
                                Text("Reward: \(mission.reward)")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.white)
                                Image("gold_icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 14, height: 14)
                            }
                            if isCompletedMission && !isSelected {
                                Text("Complete")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.green)
                            }
                        }
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
        .onAppear {
            updateTimer()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if isActiveMission {
                updateTimer()
            }
        }
    }
    
    var descriptionBody: some View {
        VStack {
            if isCompletedMission {
                // Completed mission view
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 20))
                            Text("MISSION SUCCESS!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                        }
                        
                        HStack(spacing: 4) {
                            Text("+\(mission.reward)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.textDetail)
                            Image("gold_icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        }
                    }
                    
                    Text(mission.successMessage)
                        .font(.system(size: 13))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.textDetail)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            } else if isActiveMission {
                // Check if mission is ready to complete or still running
                VStack(spacing: 20) {
                    Text(mission.description)
                        .font(.system(size: 13))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.textDetail)
                    
                    if missionManager.isReadyToComplete(mission) {
                        // Mission is ready to complete - show completion button
                        VStack(spacing: 16) {
                            Text("READY TO COMPLETE")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.green)
                            
                            Text("Success Chance: \(mission.successChances.base ?? 50)%")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(8)
                            
                            Button("Complete Mission") {
                                onComplete()
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    } else {
                        // Mission still running - show timer
                        VStack(spacing: 8) {
                            Text("TIME REMAINING")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.textDetail)
                            
                            Text(timerText)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.textOrange)
                        }
                    }
                    
                    #if DEBUG
                    // Debug button to instantly complete mission
                    Button("🐛 DEBUG: Complete Now") {
                        print("🐛 DEBUG: Button tapped for mission: \(mission.title)")
                        missionManager.debugCompleteMission(mission)
                    }
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red.opacity(0.5), lineWidth: 1)
                    )
                    #endif
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            } else {
                // Original expanded view for non-active missions
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
                            LUButton(title: "Start Mission", isLoading: isLoading, size: .small) {
                                onSelect()
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
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
    
    private func updateTimer() {
        if isActiveMission {
            timerText = missionManager.getFormattedRemainingTime(for: mission) ?? "0:00:00"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(Mission.testData) { mission in
            MissionCard(
                mission: mission,
                isSelected: true,
                isLoading: false,
                onTap: {},
                onSelect: {},
                onComplete: {}
            )
        }
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
