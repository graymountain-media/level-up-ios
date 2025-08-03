import SwiftUI

struct MissionResult {
    let mission: Mission
    let isSuccess: Bool
    let message: String
}

struct MissionResultPopupView: View {
    let result: MissionResult
    let onDismiss: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    VStack(spacing: 24) {
                        // Success/Fail Icon
                        if result.isSuccess {
                            Image("checkmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                        } else {
                            Image(systemName: "x.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.red)
                                .frame(width: 120, height: 120)
                        }
                        
                        // Success/Fail Title
                        Text(result.isSuccess ? "Mission Success!" : "Mission Failed")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.title)
                            .padding(.top, -10)
                        
                        // Mission Title
                        Text(result.mission.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.title)
                            .multilineTextAlignment(.center)
                        
                        // Success/Fail Message
                        Text(result.message)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.textDetail)
                        
                        // Reward (only for success)
                        if result.isSuccess {
                            HStack(spacing: 8) {
                                Text("Reward: \(result.mission.reward)")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .bold()
                                Image("gold_icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        
                        // Dismiss Button
                        Button(action: onDismiss) {
                            Text("OK")
                                .font(.headline)
                                .frame(minWidth: 100)
                                .padding()
                                .background(result.isSuccess ? Color.green : Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 32)
                    .padding(.horizontal, 24)
                    .overlay {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.minor.opacity(0.5), lineWidth: 2)
                            .shadow(radius: 20)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.major)
                            .shadow(radius: 20)
                    )
                    .padding(.horizontal, 24)
                    .transition(.scale)
                    .accessibilityElement(children: .combine)
                }
                .frame(minHeight: geometry.size.height)
            }
            .scrollIndicators(.hidden)
        }
        
    }
}

#Preview {
    let success =  MissionResultPopupView(
        result: MissionResult(
            mission: Mission.testData[0],
            isSuccess: true,
            message: "Excellent work! You successfully completed the mission and earned your rewards."
        ),
        onDismiss: {}
    )
    let failure = MissionResultPopupView(
        result: MissionResult(
            mission: Mission.testData[1],
            isSuccess: false,
            message: "Mission failed. Better luck next time! You can try again later."
        ),
        onDismiss: {}
    )

            
    success
}
