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
        VStack(spacing: 28) {
            // Success/Fail Icon
            Image(systemName: result.isSuccess ? "checkmark.seal.fill" : "xmark.seal.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(result.isSuccess ? .green : .red)
                .shadow(radius: 8)
            
            // Success/Fail Title
            Text(result.isSuccess ? "Mission Success!" : "Mission Failed")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            // Mission Title
            Text(result.mission.title)
                .font(.headline)
                .foregroundColor(.accentColor)
                .multilineTextAlignment(.center)
            
            // Success/Fail Message
            Text(result.message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Reward (only for success)
            if result.isSuccess {
                HStack(spacing: 8) {
                    Text("Reward: \(result.mission.reward)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Image("gold_icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                )
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
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(radius: 20)
        )
        .frame(maxWidth: 340)
        .padding(.horizontal, 24)
        .transition(.scale)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Success example
        MissionResultPopupView(
            result: MissionResult(
                mission: Mission.testData[0],
                isSuccess: true,
                message: "Excellent work! You successfully completed the mission and earned your rewards."
            ),
            onDismiss: {}
        )
        
        // Failure example
        MissionResultPopupView(
            result: MissionResult(
                mission: Mission.testData[1],
                isSuccess: false,
                message: "Mission failed. Better luck next time! You can try again later."
            ),
            onDismiss: {}
        )
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}