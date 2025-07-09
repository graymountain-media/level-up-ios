import SwiftUI

struct TimeRemainingView: View {
    let deadline: Date
    
    @State private var timeRemaining: String = ""
    @State private var timer: Timer? = nil
    
    var body: some View {
        Text(timeRemaining)
            .onAppear {
                updateTimeRemaining()
                // Create a timer that updates every second
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    updateTimeRemaining()
                }
            }
            .onDisappear {
                // Invalidate the timer when the view disappears
                timer?.invalidate()
                timer = nil
            }
    }
    
    private func updateTimeRemaining() {
        let now = Date()
        
        // If deadline is in the past, show 00:00:00
        guard deadline > now else {
            timeRemaining = "00:00:00"
            return
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: now, to: deadline)
        
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        
        // Format as HH:MM:SS
        timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    // Preview with a deadline 72 hours in the future
    let futureDate = Calendar.current.date(byAdding: .hour, value: 72, to: .now)!
    return TimeRemainingView(deadline: futureDate)
        .font(.system(size: 48, weight: .bold))
        .foregroundStyle(.orange)
}
