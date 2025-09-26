//
//  Tracking.swift
//  Level Up
//
//  Created by Jake Gray on 9/25/25.
//

import Foundation
@_spi(Frustration) import AmplitudeSwift

class Tracking: TrackingProtocol {
    private let amplitude = Amplitude(configuration: Configuration(
        apiKey: "aafd564da6ce46a9f21bd6ba03641c32",
        trackingOptions: TrackingOptions().disableTrackIpAddress(),
        autocapture: [.sessions, .appLifecycles, .screenViews, .networkTracking, .frustrationInteractions]
    ))

    func track(_ event: LUEvent) {
        amplitude.track(eventType: event.apiValue, eventProperties: event.properties)
    }

    func track(event: String, properties: [String: Any]? = nil) {
        amplitude.track(eventType: event, eventProperties: properties)
    }

    func setUserId(_ userId: String) {
        amplitude.setUserId(userId: userId)
    }

    func setUserProperties(_ properties: [String: Any]) {
        amplitude.identify(userProperties: properties)
    }

    func identifyUser(userId: String, faction: String?, heroPath: String?, level: Int, xpTotal: Int, streakDays: Int) {
        setUserId(userId)

        var properties: [String: Any] = [
            "level": level,
            "xp_total": xpTotal,
            "streak_days": streakDays,
            "platform": "ios"
        ]

        if let faction = faction {
            properties["faction"] = faction
        }

        if let heroPath = heroPath {
            properties["class"] = heroPath
        }

        setUserProperties(properties)
    }

    func reset() {
        amplitude.reset()
    }
}
