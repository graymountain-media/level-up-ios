//
//  OnboardingTips.swift
//  Level Up
//
//  Created by Jake Gray on 8/3/25.
//

import Foundation
import TipKit

struct LUTip: Tip {
    private let content: LUTipContent
    
    init(content: LUTipContent) {
        self.content = content
    }
    
    var title: Text {
        Text(content.title)
    }
    var message: Text? {
        Text(content.message)
    }
}

struct LUTipContent {
    var title: String
    var message: String
}

let onboardingTips: [LUTip] = [
    LUTip(content: .init(title: "Experience Points (XP)", message: "You gain experience points by logging workouts. 1 minute of working out = 1 XP. You must workout a minimum of 20 minutes and can only log a maximum of 60 minutes. You can only log one workout per day.")),
    LUTip(content: .init(title: "Your Level", message: "Gaining XP levels you up. Leveling up grants you and your avatar access to powerful rewards and features.")),
    LUTip(content: .init(title: "Your Avatar", message: "Your avatar is you. It represents your progress at the gym. Earn gear and other rewards that you can equip on your avatar.")),
    LUTip(content: .init(title: "Streak", message: "Work out every day to increase your streak. One rest day between workouts is allowed to maintain your streak. At the end of the second day, your streak resets if you don’t log a workout."))
]
