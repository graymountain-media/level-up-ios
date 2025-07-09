//
//  AvatarView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI

enum GearType: Int, CaseIterable, Identifiable {
    case helmet
    case chest
    case pants
    case boots
    case gloves
    case weapon
    
    var id: Int {
        self.rawValue
    }
    
    var iconName: String {
        switch self {
        case .helmet:
            return "helmet"
        case .chest:
            return "chest"
        case .gloves:
            return "gloves"
        case .boots:
            return "boots"
        case .weapon:
            return "weapon"
        case .pants:
            return "pants"
        }
    }
}

struct AvatarView: View {
    @State var progressValue: Double = 0.80
    var body: some View {
        VStack {
//            FeatureHeader(titleImageName: "avatar_title")
            ZStack {
                AvatarBaseView()
                VStack {
                    heroInfo
                    Spacer()
                }
            }
            .clipped()
        }
        .background(Color.major.ignoresSafeArea())
    }
    
    var heroInfo: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("William Vengence")
                .font(.system(size: 34, weight: .semibold))
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Level 99")
                        .font(.headline)
                    Text("100 XP to next Level")
                        .font(.subheadline)
                }
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .frame(height: 12)
                        .foregroundColor(Color.white.opacity(0.2))
                    
                    // Progress fill with gradient
                    Capsule()
                        .frame(width: (UIScreen.main.bounds.width - 152) * progressValue, height: 12)
                        .foregroundStyle(LinearGradient(
                            colors: [Color(red: 0.3, green: 0.8, blue: 0.3), Color.green],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                    
                    // White outline
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                        .frame(height: 12)
                }
                .frame(height: 12)
                
            }
            .padding(.horizontal, 40)
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Text("Streak:")
                        .bold()
                    Text("114 days")
                    Image("fire-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                }
            }
            .padding(.horizontal, 40)
        }
        .padding(.top, 36)
        .padding(.horizontal, 36)
        .foregroundStyle(.white)
    }
}

#Preview {
    AvatarView()
}
