//
//  FactionOverviewView.swift
//  Level Up
//
//  Created by Sam Smith on 9/2/25.
//
import SwiftUI

struct FactionOverviewView: View {
    let faction: FactionDetails

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                FactionHeader(faction: faction)
                    .padding(.bottom, 12)
                FactionDivider()
                
                TopLeadersView(leaders: faction.topLeaders) // Use real data
                FactionDivider()
                
                MemberTraitsView(description: faction.description, traits: ["Trait 1", "Trait 2"]) // Use real data
                FactionDivider()
                
                FactionStatsView(faction: faction) // Pass the entire model
            }
            .padding(.horizontal, 24)
        }
    }
}


struct FactionHeader: View {
    let faction: FactionDetails

    var body: some View {
        VStack(alignment: .center) {
            Image(faction.iconName) // Use data from the model
                .resizable()
                .frame(width: 48, height: 48)
            
            Spacer().frame(height: 20)
            
            Text(faction.name) // Use data from the model
                .font(.largeTitle)
                .foregroundStyle(.title)
            
            Spacer().frame(height: 12)
            
            Text(faction.slogan) // Use data from the model
                .font(.body)
                .foregroundStyle(.pulseforge)
                .textCase(.uppercase)
        }
    }
}

struct TopLeadersView: View {
    let leaders: [Leader]

    var body: some View {
        VStack(alignment: .center, spacing: 16) { // Added spacing
            Text("Top Members")
                .font(.headline)
                .foregroundStyle(.textOrange)
                .padding(.bottom, 12)
                .textCase(.uppercase)
            
            HStack(alignment: .top, spacing: 12) { // Spacing between cards
                ForEach(leaders) { leader in
                    LeaderCardView(leader: leader)
                }
            }
        }
    }
}

// A sub-view for each leader's card
struct LeaderCardView: View {
    let leader: Leader

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(leader.rank)
                .font(.caption)
                .foregroundStyle(.white)
            
            VStack {
                ZStack(alignment: .bottom) { // For the level badge
                    Image(leader.avatarName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                    
                    Text("\(leader.level)")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue) // Or a specific level color
                        .offset(x: 0, y: 5) // Position the badge
                }
                .padding(.bottom, 4) // Space between avatar and name
                
                Text(leader.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text("\(leader.points)")
                    .font(.subheadline)
                    .foregroundStyle(.blue) // The specific blue color
            }
            .padding(12) // Padding inside the card
            .frame(width: 100) // Fixed width for cards, adjust as necessary
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.1, green: 0.2, blue: 0.25)) // Dark background color
                    .stroke(leader.rank == "Faction Leader" ? Color.yellow : Color.blue, lineWidth: 2) // Border color
            )
        }
    }
}

struct MemberTraitsView: View {
    let description: String
    let traits: [String]

    var body: some View {
        VStack(alignment: .center) {
            Text("Member Traits")
                .font(.headline)
                .foregroundStyle(.textOrange)
                .padding(.bottom, 12)
                .textCase(.uppercase)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.textDetail)
                .padding(.bottom, 8)
            
            HStack {
                ForEach(traits, id: \.self) { trait in
                    Spacer()
                    MemberTraitView(trait: trait)
                }
                Spacer()
            }
        }
    }
}

struct MemberTraitView: View {
    let trait: String
    
    var body: some View {
        HStack {
            Image("hunter_icon")
                .resizable()
                .frame(width: 16, height: 16)
            
            Text(trait)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

struct FactionStatsView: View {
    let faction: FactionDetails
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Faction Stats")
                .font(.headline)
                .foregroundStyle(.textOrange)
                .textCase(.uppercase)
            
            HStack(alignment: .top) {
                FactionStatView(statType: .weeklyXP, value: faction.weeklyXP) // Pass real data
                Spacer()
                FactionStatView(statType: .memberCount, value: faction.memberCount) // Pass real data
                Spacer()
                FactionStatView(statType: .levelLine, value: faction.levelLine) // Pass real data
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
                    .foregroundStyle(.title)
                    .textCase(.uppercase)
                
                Text(String(value))
                    .font(.body)
                    .foregroundStyle(.textInput)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(.textfieldBorder)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.minor, lineWidth: 2)
            )
            
            if statType == .levelLine {
                Text("*Average Weekly XP per Faction member")
                    .font(.mainFont(size: 8))
                    .foregroundStyle(.title)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// The enum can remain a top-level type or be nested inside FactionStatView if preferred.
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
