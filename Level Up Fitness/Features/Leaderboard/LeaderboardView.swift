//
//  LeaderboardView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/4/25.
//

import SwiftUI

// MARK: - Models
struct Player: Identifiable {
    let id = UUID()
    let name: String
    let classType: String
    let score: Int
    let imageName: String
    let iconType: IconType
}

enum IconType {
    case lightning
    case eye
    case skull
    case none
}

struct LeaderboardView: View {
    // MARK: - Properties
    @State private var players: [Player] = [
        Player(name: "STRIKER", classType: "ROGUE", score: 35_080, imageName: "player1", iconType: .lightning),
        Player(name: "NYLA_X", classType: "DRAGOON", score: 32_300, imageName: "player2", iconType: .eye),
        Player(name: "FENRIR", classType: "STRIDER", score: 31_003, imageName: "player3", iconType: .lightning),
        Player(name: "KORVUS", classType: "BRUTE", score: 23_790, imageName: "player4", iconType: .lightning),
        Player(name: "KIRA", classType: "ASSASSIN", score: 20_231, imageName: "player5", iconType: .eye),
        Player(name: "AHMAYA", classType: "BRUTE", score: 15_488, imageName: "player6", iconType: .skull)
    ]
    
    let factionName = "PULSEFORGE"
    let factionXP = 89_397
    let streakDays = 74
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            Color.major
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    FeatureHeader(titleImageName: "leaderboard_title")
                    
                    // Faction section
                    VStack(spacing: 16) {
                        factionSection
                        
                        // Players list
                        playersListSection
                        
                        // Streak section
                        streakSection
                    }
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.majorDark)
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Faction Section
    private var factionSection: some View {
        ZStack {
            CustomBorderShape()
                .stroke(Color.border)
            CustomBorderShape(cornerWidth: 7)
                .stroke(Color.border)
                .padding(6)
            
            HStack(spacing: 16) {
                // Faction logo
                Image(systemName: "chevron.up.chevron.down")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color(hex: "1D9AAA"))
                    .frame(width: 40, height: 30)
                .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("FACTION WAR")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(factionName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "1D9AAA"))
                }
                
                Spacer(minLength: 4)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(factionXP) XP")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "E89B28"))
                    
                    // XP progress bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: "0A1A1F"))
                            .frame(width: 100, height: 10)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.mint)
                            .frame(width: 60, height: 10)
                            .shadow(color: .white, radius: 4)
                    }
                }
                .padding(.trailing, 16)
            }
            .padding(.vertical, 16)
        }
        .frame(height: 80)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Players List Section
    private var playersListSection: some View {
        ZStack {
            CustomBorderShape()
                .stroke(Color.border)
            
            VStack(spacing: 16) {
                ForEach(players) { player in
                    playerRow(player: player)
                }
            }
            .padding(.vertical, 16)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Player Row
    private func playerRow(player: Player) -> some View {
        HStack(spacing: 12) {
            // Player image
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "1D9AAA").opacity(0.3))
                    .frame(width: 50, height: 50)
                
                // In a real app, you would use actual images
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color(hex: "1D9AAA"))
                    .frame(width: 30, height: 30)
            }
            .padding(.leading, 16)
            VStack(spacing: 4) {
                Capsule()
                    .fill(.minor)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .opacity(0.2)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(player.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "1D9AAA"))
                        
                        Text(player.classType)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        // Icon based on player type
                        if player.iconType != .none {
                            Image(systemName: iconForType(player.iconType))
                                .foregroundColor(iconColorForType(player.iconType))
                                .frame(width: 20, height: 20)
                        }
                        
                        Text(formatScore(player.score))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(scoreColor(index: players.firstIndex(where: { $0.id == player.id }) ?? 0))
                    }
                }

                Capsule()
                    .fill(.minor)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .opacity(0.2)
            }
            .padding(.trailing, 16)
        }
    }
    
    // MARK: - Streak Section
    private var streakSection: some View {
        ZStack {
            CustomBorderShape()
                .stroke(Color.border)
            
            HStack(spacing: 16) {
                // Player image
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "1D9AAA").opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color(hex: "1D9AAA"))
                        .frame(width: 30, height: 30)
                }
                .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("PULSE STREAK")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("KORVUS")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "1D9AAA"))
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(Color(hex: "E89B28"))
                        .frame(width: 20, height: 20)
                    
                    Text("\(streakDays) DAYS")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "E89B28"))
                        .fixedSize()
                }
                .padding(.trailing, 16)
            }
            .padding(.vertical, 16)
        }
        .frame(height: 80)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Helper Functions
    private func iconForType(_ type: IconType) -> String {
        switch type {
        case .lightning:
            return "bolt.fill"
        case .eye:
            return "eye.fill"
        case .skull:
            return "flame.fill"
        case .none:
            return ""
        }
    }
    
    private func iconColorForType(_ type: IconType) -> Color {
        switch type {
        case .lightning, .skull:
            return Color(hex: "E89B28")
        case .eye:
            return Color(hex: "1D9AAA")
        case .none:
            return .clear
        }
    }
    
    private func formatScore(_ score: Int) -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: score), number: .decimal)
    }
    
    private func scoreColor(index: Int) -> Color {
        if index < 3 {
            return Color(hex: "E89B28") // Gold for top 3
        } else {
            return Color(hex: "E89B28") // Same color for others in this design
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    LeaderboardView()
}
