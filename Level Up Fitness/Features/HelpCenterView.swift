//
//  HelpCenterView.swift
//  Level Up
//
//  Created by Jake Gray on 8/1/25.
//

import SwiftUI
import FactoryKit

struct HelpCenterSection: Identifiable {
    var id: UUID = UUID()
    var header: String
    var content: String
}

struct HelpCenterContent: Identifiable {
    var id: UUID = UUID()
    var title: String
    var sections: [HelpCenterSection]
    var headers: [String] {
        return sections.map { $0.header }
    }
}

fileprivate let helpCenterContent: [HelpCenterContent] = [
    HelpCenterContent(
        title: "Avatar",
        sections: [
            HelpCenterSection(header: "i. Experience Points", content: "You gain XP by logging workouts. 1 minute = 1 XP. 20 minutes is the minimum to log a workout and you can log 60 minutes max per day. 1 workout per day is allowed."),
            HelpCenterSection(header: "ii. Path", content: "Your Path represents how you like to workout. Currently, there are 7 paths to choose from:\n\nBrute - Strength Only\nRanger - Cardio Only\nSentinel - Functional Only\nHunter - Strength and Cardio\nJuggernaut - Strength and Functional\nStrider - Cardio and Functional\nChampion - All 3 Equal\n\nWhen completing group missions, you can receive bonuses to your success chance by grouping with members from a specific Path."),
            HelpCenterSection(header: "iii. Faction", content: "Every member will be in one of four factions. Factions compete for end-of-season-rewards. Changing factions is difficult, so it’s recommended that you talk to your friends before joining one."),
            HelpCenterSection(header: "iv. Streaks", content: "Work out once per day to increase your streak count. 1 rest day between workouts is allowed to maintain your streak. At midnight on the second day without a logged workout, your streak resets."),
            HelpCenterSection(header: "v. Item Slots", content: "Equip items purchased in the shop to receive an XP bonus when you work out."),
            HelpCenterSection(header: "vi. Inventory", content: "This is where you store items you’ve purchased but don’t currently have equipped. Tap the item in your bag to equip or sell it.")
        ]
    ),
    HelpCenterContent(
        title: "Shop",
        sections: [
            HelpCenterSection(header: "i. XP Bonus", content: "Each item gives you a small bonus to XP. Higher level items grant a higher bonus. Some items can only be acquired if you’re on a certain Path."),
            HelpCenterSection(header: "ii. Cost", content: "Items cost gold to purchase. Earn gold by completing missions. Higher level items require a certain streak score to purchase.")
        ]
    ),
    HelpCenterContent(
        title: "Mission Board",
        sections: [
            HelpCenterSection(header: "i. Missions", content: "Missions are passive events that run outside of the gym. They award gold that can be used to purchase items. After finishing your missions for the day, you must log a workout before you can start more missions. Level up to unlock more missions."),
            HelpCenterSection(header: "ii. Success Chance", content: "Every mission has a success chance. You’ll know if you succeeded on the mission once it completes."),
            HelpCenterSection(header: "iii. Grouping", content: "Grouping can increase your success chance on a mission. Grouping with members of a certain Path (if the mission offers this bonus) can increase your success chance further.")
        ]
    ),
    HelpCenterContent(
        title: "Leaderboards",
        sections: [
            HelpCenterSection(header: "i. Rankings", content: "There are three types of leaderboards: XP, streak, and faction. Be at the top of the leaderboard at the end of the season to earn special rewards.")
        ]
    ),
    HelpCenterContent(
        title: "Workouts",
        sections: [
            HelpCenterSection(header: "i. Logging a Workout", content: "Log a minimum of 20 minutes to qualify. A maximum of 60 minutes per day is allowed. You can only log 1 workout per day."),
            HelpCenterSection(header: "ii. Sports", content: "If logging a workout where a sport is involved (soccer, basketball, tennis, etc.), then choose both cardio and functional as your workout type.")
        ]
    ),
    HelpCenterContent(
        title: "Account",
        sections: [
            HelpCenterSection(header: "i. Avatar Name", content: "While your avatar name will be visible to other members, your personal information won’t. Invite other members using their avatar name for group content."),
            HelpCenterSection(header: "ii. Subscription", content: "Basic information about your subscription appears on the Account tab. If you’d like to make changes to your subscription, click the button below.")
        ]
    ),
]

struct HelpCenterView: View {
    @InjectedObservable(\.appState) var appState
    @State var selectedSection: HelpCenterContent?
    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        appState.isShowingHelp = false
                    }

                }
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Button {
                                    withAnimation {
                                        appState.isShowingHelp = false
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.textfieldBorder)
                                }
                                
                            }
                            HStack {
                                Spacer()
                                Text("Index")
                                    .font(.system(size: 16))
                                    .bold()
                                    .underline()
                                    .foregroundStyle(.textOrange)
                                Spacer()
                            }
                            ForEach(helpCenterContent, id: \.title) { content in
                                Button(action: {
                                    selectedSection = content
                                }, label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(content.title)
                                            .font(.headline)
                                            .foregroundStyle(.textOrange)
                                        Text(content.headers.joined(separator: "\n"))
                                            .font(.caption)
                                            .foregroundStyle(.white)
                                            .multilineTextAlignment(.leading)
                                        
                                    }
                                })
                            }
                        }
                        .padding()
                        .frame(width: (geometry.size.width * 0.45))
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.major)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 2)
                        }
                    }
                    .scrollIndicators(.hidden)
                    if let selectedSection {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 30) {
                                detailView(for: selectedSection)
                            }
                            .foregroundStyle(.white)
                            .padding()
                            //                            .frame(width: (geometry.size.width * 0.5) - 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.major)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 2)
                            }
                        }
                        .padding(.top, 32)
                        .scrollIndicators(.hidden)
                    }
                }
                
            }
            
        }
    }
    
    func detailView(for selectedSection: HelpCenterContent) -> some View {
        VStack(spacing: 14) {
            Text(selectedSection.title)
            ForEach(selectedSection.sections) { section in
                VStack(alignment: .leading, spacing: 8) {
                    Text(section.header)
                        .font(.system(size: 12, weight: .medium))
                    Text(section.content)
                        .font(.system(size: 10))
                }
            }
        }
    }
}

#Preview {
    HelpCenterView()
}
