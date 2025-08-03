import SwiftUI

struct MessagePopover: View {
    var imageName: String?
    let title: String
    let message: String
    let ctaTitle: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
            }
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.title)
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.textDetail)
            LUButton(title: ctaTitle) {
                onDismiss()
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
}

#Preview {
    MessagePopover(imageName: "checkmark", title: "Mission Complete!", message: "A mission is ready to complete! Check the Mission Board to claim your rewards.", ctaTitle: "Go to Missions") {
        
    }
}
