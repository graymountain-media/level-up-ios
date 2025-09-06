//
//  FactionSelectionView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/6/25.
//

import SwiftUI

struct FactionSelectionView: View {
    let onFactionSelected: (Faction) -> Void
    let onDismiss: () -> Void
    
    @State private var selectedFaction: Faction?
    @State private var showContent = false
    @State private var showFactionGrid = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                if !showFactionGrid {
                    Text("UNLOCKED!")
                        .font(.mainFont(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.textOrange)
                        .opacity(showContent ? 1.0 : 0.0)
                }
                Text("CHOOSE YOUR\nFACTION")
                    .font(.mainFont(size: 40))
                    .bold()
                    .foregroundColor(.title)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .scaleEffect(showContent ? 1.0 : 0.8)
                    .opacity(showContent ? 1.0 : 0.0)
                
                LUDivider()
            }
            Spacer()
            if showFactionGrid {
                factionGridView
                    .scaleEffect(showContent ? 1.0 : 0.9)
                    .opacity(showContent ? 1.0 : 0.0)
            } else {
                factionCard
                    .scaleEffect(showContent ? 1.0 : 0.9)
                    .opacity(showContent ? 1.0 : 0.0)
            }
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .mainBackground()
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
        }
        .fullScreenCover(item: $selectedFaction) { faction in
            FactionDetailView(
                faction: faction,
                onFactionSelected: { selectedFaction in
                    self.selectedFaction = nil // Dismiss detail view
                    onFactionSelected(selectedFaction) // Complete faction selection
                },
                onDismiss: {
                    selectedFaction = nil // Just dismiss detail view
                }
            )
        }
    }
    
    var factionCard: some View {
        VStack(spacing: 24) {
            // Faction Icon
            if let selectedFaction {
                Image(selectedFaction.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.cyan)
            }
            
            VStack(spacing: 16) {
                Image("faction_icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 65, height: 65)
                // Main description
                Text("Choose your allegiance wisely.\nDecide who you fight beside, what stories unfold, and how your legacy is written. Make sure to select the one that feels like you — this isn't just a team, it's who you are becoming.")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                Rectangle()
                    .fill(.white.opacity(0.1))
                    .frame(height: 1)
                    .padding(.horizontal, 60)
                // Territory claim description
                Text("Territorial Claim: Factions fight and compete for influence and power within the Nexus. It is advised that you speak with your friends before picking, otherwise they may become your foes.")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                
                // Choose Button
                LUButton(title: "CHOOSE FACTION", size: .small) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showFactionGrid = true
                    }
                }
            }
        }
        .padding(.vertical)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.08, green: 0.2, blue: 0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    var factionGridView: some View {
        VStack(spacing: 24) {
            Text("This choice shapes your journey.")
                .font(.system(size: 16))
                .foregroundColor(.textDetail)
                .italic()
            
            // Faction Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 20) {
                ForEach(Faction.allCases, id: \.self) { faction in
                    factionCard(for: faction)
                }
            }
        }
    }
    
    func factionCard(for faction: Faction) -> some View {
        VStack(spacing: 6) {
            Text(faction.description)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Image(faction.shieldImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 115, height: 150)
            
            // Learn More Button
            Button("Learn More") {
                selectedFaction = faction
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.textOrange)
            )
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Faction Model
enum Faction: String, CaseIterable, Identifiable, Codable, Equatable {
    case echoreach
    case pulseforge
    case voidkind
    case neurospire
    
    var id: String {
        self.name
    }
    
    var name: String {
        switch self {
        case .echoreach:
            return "Echoreach"
        case .pulseforge:
            return "Pulseforge"
        case .voidkind:
            return "Voidkind"
        case .neurospire:
            return "Neurospire"
        }
    }
    
    var description: String {
        switch self {
        case .echoreach:
            return "Creative and Calculating"
        case .pulseforge:
            return "Relentless and Passionate"
        case .voidkind:
            return "Dark and Intense"
        case .neurospire:
            return "Investigative and Visionary"
        }
    }
    
    var iconName: String {
        switch self {
        case .echoreach:
            return "echoreach_icon"
        case .pulseforge:
            return "pulseforge_icon"
        case .voidkind:
            return "voidkind_icon"
        case .neurospire:
            return "neurospire_icon"
        }
    }
    
    var shieldImageName: String {
        switch self {
        case .echoreach:
            return "echoreach_shield"
        case .pulseforge:
            return "pulseforge_shield"
        case .voidkind:
            return "voidkind_shield"
        case .neurospire:
            return "neurospire_shield"
        }
    }
    
    // Convert database string to Faction enum
    static func fromString(_ string: String) -> Faction? {
        switch string.lowercased() {
        case "echoreach":
            return .echoreach
        case "pulseforge":
            return .pulseforge
        case "voidkind":
            return .voidkind
        case "neurospire":
            return .neurospire
        default:
            return nil
        }
    }
    
    // MARK: - Overview Content
    var main_image: String {
        switch self {
        case .echoreach:
            return "echoreach_icon"
        case .pulseforge:
            return "pulseforge_faction"
        case .voidkind:
            return "voidkind_faction"
        case .neurospire:
            return "neurospire_faction"
        }
    }
    
    var slogan: String {
        switch self {
        case .echoreach:
            return "The spark that lights the night"
        case .pulseforge:
            return "The fire that breaks the stone"
        case .voidkind:
            return "The shadow that hides the knife"
        case .neurospire:
            return "The thought that pierces the veil"
        }
    }
    
    var memberTraits: [String] {
        switch self {
        case .echoreach:
            return ["Bold", "Creative", "Unconventional"]
        case .pulseforge:
            return ["Ambitious", "Fiery", "Determined"]
        case .voidkind:
            return ["Deep", "Calculating", "Mysterious"]
        case .neurospire:
            return ["Perceptive", "Innovative", "Cerebral"]
        }
    }
    
    var memberTraitsDescription: String {
        switch self {
        case .echoreach:
            return "Echoreach turns chaos into opportunity. Their weapon is their ability to find flaws that no one else can see. They are artists in motion."
        case .pulseforge:
            return "Pulseforge burn with a fire that refuses to be contained. Their drive ignites those around them and it turns obstacles into fuel. They are unstoppable."
        case .voidkind:
            return "Voidkind move like shadows given purpose. They are silent, steady, and watchful. Their every action hides a lethal precision."
        case .neurospire:
            return "Neurospire see the world as patterns waiting to be unraveled. They forge their curiosity into power, but it also drives them toward secrets best left alone."
        }
    }
    
    var traitIcons: [String] {
        switch self {
        case .echoreach:
            return ["bold", "creative", "unconventional"]
        case .pulseforge:
            return ["ambitious", "fiery", "determined"]
        case .voidkind:
            return ["deep", "calculating", "mysterious"]
        case .neurospire:
            return ["perceptive", "innovative", "cerebral"]
        }
    }

    var baseColor: Color {
        switch self {
        case .echoreach:
            return .echoreach
        case .pulseforge:
            return .pulseforge
        case .voidkind:
            return .voidkind
        case .neurospire:
            return .neurospire
        }
    }
}

#Preview {
    FactionSelectionView(
        onFactionSelected: { faction in
            print("Selected faction: \(faction.name)")
        },
        onDismiss: {}
    )
}
