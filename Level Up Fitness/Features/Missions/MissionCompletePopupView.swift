import SwiftUI

struct MissionCompletePopupView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.green)
                .shadow(radius: 8)
            Text("Mission Complete!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Button(action: onDismiss) {
                Text("OK")
                    .font(.headline)
                    .frame(minWidth: 100)
                    .padding()
                    .background(Color.accentColor)
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
