//
//  TipDefinitions.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/4/25.
//

import Foundation

// MARK: - Avatar Tips
extension SequentialTipsManager {
    static func avatarTips() -> SequentialTipsManager {
        let tips = [
            TipContent(
                id: 0,
                title: "Welcome to the Nexus",
                message: "The Nexus is an elite academy that trains the next generation of warriors to fight the Invasion. Recruits like you are desperately needed!\n\nKeep reading to learn how your time at the Nexus will work.",
                position: .center
            ),
            TipContent(
                id: 1,
                title: "Experience Points (XP)",
                message: "You gain experience points by logging training sessions. 1 minute of exercise = 1 XP. You must work out a minimum of 20 minutes and can only log a maximum of 60 minutes per day.",
                position: .bottom
            ),
            TipContent(
                id: 2,
                title: "Your Level",
                message: "Gaining XP levels you up. Leveling up grants you access to powerful rewards.",
                position: .bottom
            ),
            TipContent(
                id: 3,
                title: "Your Avatar",
                message: "This is you. It represents your progress toward becoming the elite soldier that the Nexus, and humanity, needs.",
                position: .top
            ),
            TipContent(
                id: 4,
                title: "Streak",
                message: "Work out every day to increase your streak. One rest day between workouts is allowed to maintain your streak. At the end of the second day, your streak resets if you don’t log a workout.",
                position: .bottom
            ),
            TipContent(
                id: 5,
                title: "",
                message: "",
                position: .top,
                requiresTap: true,
            )
        ]
        
        return SequentialTipsManager(tips: tips, storageKey: "avatar_onboarding_completed")
    }
}

// MARK: - Workout Tips
extension SequentialTipsManager {
    static func workoutTips() -> SequentialTipsManager {
        let manager = SequentialTipsManager(tips: [], storageKey: "workout_onboarding_completed")
        manager.registerSingleTip(
            key: "workout_welcome",
            tip: TipContent(
                id: 0,
                title: "Log Your Workouts",
                message: "Be sure to log your training sessions after you finish!\n\nFor workout type, select all that apply. Don’t include warm up and cool down exercises. How you train will decide how you will help the Nexus defeat the Invasion. Now go train! ",
                position: .top
            )
        )
        
        manager.registerSingleTip(
            key: "workout_guidelines",
            tip: TipContent(
                id: 1,
                title: "User Guidelines",
                message: "1 min = 1 XP. 20 minutes minimum, 60 minutes max.\n\nCount your warm up/cool down toward total time, but don’t count it toward your workout type. Ex: If strength training and you do a short warm up on the treadmill, don’t select Cardio as your workout type for that day.",
                position: .top
            )
        )
        
        return manager
    }
}

// MARK: - Mission Tips
extension SequentialTipsManager {
    static func missionTips() -> SequentialTipsManager {
        
        let manager = SequentialTipsManager(tips: [], storageKey: "mission_onboarding_completed")
        // Register single tips
        manager.registerSingleTip(
            key: "welcome",
            id: 0,
            title: "Mission Board",
            message: "It's time to go on a mission, which you can start after each workout. Missions are important--through them you earn money to buy gear. Gear gives you a small XP bonus when you exercise.\n\nTap the mission to start it.",
            position: .bottom
        )
        
        manager.registerSingleTip(
            key: "first_expansion",
            id: 1,
            title: "Duration & Success Chance",
            message: "Missions auto-complete after their duration ends. Earn gear by completing missions, and learn more about the mystery surrounding the Nexus and its neighboring city, Westhaven.",
            position: .top
        )
        
        return manager
    }
}

// MARK: - Item Shop Tips
extension SequentialTipsManager {
    static func itemShopTips() -> SequentialTipsManager {
        let tips = [
            TipContent(
                id: 0,
                title: "Item Shop",
                message: "Spend your gold on equipment for small XP bonuses. Higher level equipment provides higher bonuses.",
                position: .center
            )
        ]
        
        return SequentialTipsManager(tips: tips, storageKey: "item_shop_onboarding_completed")
    }
}
