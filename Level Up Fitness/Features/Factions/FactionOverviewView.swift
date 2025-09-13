//
//  FactionOverviewView.swift
//  Level Up
//
//  Created by Sam Smith on 9/2/25.
//
import SwiftUI

struct FactionOverviewView: View {
    let factionDetails: FactionDetails

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                FactionHeader(faction: factionDetails.faction)
                    .padding(.bottom, 12)
                FactionDivider()
                
                TopLeadersView(
                    leaders: factionDetails.topLeaders,
                    faction: factionDetails.faction
                )
                FactionDivider()
                
                MemberTraitsView(
                    description: factionDetails.faction.memberTraitsDescription,
                    traits: factionDetails.faction.memberTraits,
                    traitIcons: factionDetails.faction.traitIcons
                )
                FactionDivider()
                
                FactionStatsView(faction: factionDetails)
            }
            .padding(.horizontal, 24)
        }
    }
}


struct FactionHeader: View {
    let faction: Faction

    var body: some View {
        VStack(alignment: .center) {
            Image(faction.main_image)
                .resizable()
                .frame(width: 66, height: 66)
            
            Spacer().frame(height: 20)
            
            Text(faction.name)
                .font(.mainFont(size: 32))
                .fontWeight(.bold)
                .foregroundStyle(.title)
            
            Spacer().frame(height: 12)
            
            Text(faction.slogan)
                .font(.body)
                .foregroundStyle(faction.baseColor)
                .textCase(.uppercase)
        }
    }
}

struct TopLeadersView: View {
    let leaders: [Leader]
    let faction: Faction

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Top Members")
                .font(.mainFont(size: 20))
                .fontWeight(.bold)
                .foregroundStyle(.factionHomeSectionTitle)
                .padding(.bottom, 12)
                .textCase(.uppercase)
            
            HStack(alignment: .top, spacing: 12) {
                ForEach(leaders) { leader in
                    LeaderCardView(leader: leader, factionType: faction)
                }
            }
        }
    }
}

struct LeaderCardView: View {
    let leader: Leader
    let factionType: Faction

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(leader.rank ?? "")
                .font(.caption)
                .foregroundStyle(.generalText)
            
            VStack {
                ProfilePicture(
                    url: leader.profilePictureUrl,
                    level: leader.level
                )
                .frame(width: 60, height: 60)
                .padding(.bottom, 4)
                
                Text(leader.avatarName)
                    .font(.mainFont(size: 14))
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundStyle(.title)
                    .multilineTextAlignment(.center)
                
                Text("\(leader.xpPoints)")
                    .font(.subheadline)
                    .foregroundStyle(.numbers)
            }
            .padding(12)
            .frame(width: 100)
            .frame(minHeight: 128)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.factionCardBg)
                    .stroke(leader.rank == "Faction Leader" ? .factionHomeSectionTitle : .factionCardBorder, lineWidth: 2)
            )
        }
    }
}

struct MemberTraitsView: View {
    let description: String
    let traits: [String]
    let traitIcons: [String]

    var body: some View {
        VStack(alignment: .center) {
            Text("Member Traits")
                .font(.mainFont(size: 20))
                .fontWeight(.bold)
                .foregroundStyle(.factionHomeSectionTitle)
                .padding(.bottom, 12)
                .textCase(.uppercase)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.generalText)
                .padding(.bottom, 8)
            
            HStack {
                ForEach(Array(traits.enumerated()), id: \.offset) { index, trait in
                    Spacer()
                    MemberTraitView(trait: trait, iconName: traitIcons[index])
                }
                Spacer()
            }
        }
    }
}

struct MemberTraitView: View {
    let trait: String
    let iconName: String
    
    var body: some View {
        HStack {
            Image(iconName)
                .resizable()
                .frame(width: 16, height: 16)
            
            Text(trait)
                .font(.body)
                .foregroundStyle(.generalText)
        }
    }
}

struct FactionStatsView: View {
    let faction: FactionDetails
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Faction Stats")
                .font(.mainFont(size: 20))
                .fontWeight(.bold)
                .foregroundStyle(.factionHomeSectionTitle)
                .textCase(.uppercase)
            
            HStack(alignment: .top) {
                FactionStatView(statType: .weeklyXP, value: faction.weeklyXP)
                Spacer()
                FactionStatView(statType: .memberCount, value: faction.memberCount)
                Spacer()
                FactionStatView(statType: .levelLine, value: faction.levelLine)
            }
        }
    }
}

struct FactionStatView: View {
    let statType: FactionStatType
    let value: Int
    
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Text(statType.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.generalText)
                    .textCase(.uppercase)
                
                Text(String(value))
                    .font(.body)
                    .foregroundStyle(.numbers)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(.factionCardBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.factionCardBorder, lineWidth: 2)
            )
            
            if statType == .levelLine {
                Text("*Average Weekly XP per Faction member")
                    .font(.system(size: 8))
                    .foregroundStyle(.generalText)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

enum FactionStatType: String, CaseIterable {
    case weeklyXP, memberCount, levelLine
    
    var displayName: String {
        switch self {
        case .weeklyXP: return "Weekly XP"
        case .memberCount: return "Members"
        case .levelLine: return "Level Line*"
        }
    }
}

struct FactionDivider: View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .overlay(.textfieldBorder)
            .padding(.vertical, 12)
    }
}

#Preview {
    let mockLeaders = [
        Leader(
            avatarName: "Commander Alpha",
            profilePictureUrl: "",
            level: 25,
            xpPoints: 200,
            rank: "Faction Leader"
        ),
        Leader(
            avatarName: "Beta Squad",
            profilePictureUrl: "",
            level: 22,
            xpPoints: 1000,
            rank: "Lieutenant"
        ),
        Leader(
            avatarName: "Gamma Unit",
            profilePictureUrl: "",
            level: 20,
            xpPoints: 8000,
            rank: "Sergeant"
        )
    ]
    
    let mockFactionDetails = FactionDetails(faction: .echoreach, weeklyXP: 45000, memberCount: 127, topLeaders: mockLeaders)
    
    FactionOverviewView(factionDetails: mockFactionDetails)
        .mainBackground()
}
