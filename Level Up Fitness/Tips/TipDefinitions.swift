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
                title: "Experience Points (XP)",
                message: "You gain experience points by logging workouts. 1 minute of working out = 1 XP. You must workout a minimum of 20 minutes and can only log a maximum of 60 minutes per day.",
                position: .bottom
            ),
            TipContent(
                id: 1,
                title: "Your Level",
                message: "Gaining XP levels you up. Leveling up grants you and your avatar access to powerful rewards and features.",
                position: .bottom
            ),
            TipContent(
                id: 2,
                title: "Your Avatar",
                message: "Your avatar is you. It represents your progress at the gym. Earn gear and other rewards that you can equip on your avatar.",
                position: .top
            ),
            TipContent(
                id: 3,
                title: "Streak",
                message: "Work out every day to increase your streak. One rest day between workouts is allowed to maintain your streak. At the end of the second day, your streak resets if you don't log a workout.",
                position: .bottom
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
                message: "Be sure to log your workout after you finish!\n\nFor workout type, select all that apply. Don’t include warm up and cool down exercises. How you workout will define your place in this world. Now go enjoy your workout! ",
                position: .bottom
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
            message: "Missions auto-complete after its duration ends. Earn powerful items by completing missions, and learn more about the mystery surrounding Nova City, too.",
            position: .top
        )
        
        return manager
    }
}
