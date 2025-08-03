import Foundation
import UserNotifications

final class MissionNotificationManager {
    static let shared = MissionNotificationManager()
    
    private init() {}
    
    func requestAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus != .authorized else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }
    
    func scheduleMissionCompletionNotification(for mission: UserMission) {
        let content = UNMutableNotificationContent()
        content.title = "Mission Complete!"
        content.body = "Your mission is ready to resolve."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(mission.finishAt.timeIntervalSinceNow, 1), repeats: false)
        let request = UNNotificationRequest(identifier: "mission_\(mission.missionId)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func removeMissionNotification(for mission: Mission) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["mission_\(mission.id)"])
    }
}
