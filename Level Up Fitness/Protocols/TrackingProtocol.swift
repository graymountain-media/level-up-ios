import Foundation

protocol TrackingProtocol {
    func track(_ event: LUEvent)
    func track(event: String, properties: [String: Any]?)
    func setUserId(_ userId: String)
    func setUserProperties(_ properties: [String: Any])
    func identifyUser(userId: String, faction: String?, heroPath: String?, level: Int, xpTotal: Int, streakDays: Int)
    func reset()
}