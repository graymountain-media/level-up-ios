//
//  FactionDetailView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/6/25.
//

import SwiftUI

struct FactionDetailView: View {
    let faction: Faction
    let onFactionSelected: (Faction) -> Void
    let onDismiss: () -> Void
    
    @State private var showContent = false
    
    
    var bodyText: String {
        switch faction {
        case .echoreach:
            """
            Members of Echoreach are vibrant souls who harness their creativity and imagination in combat. Unafraid to break convention, they thrive on experimentation, seeing possibilities where others see chaos. Their emotions run deep, and they harness that energy to get inside your head. Some members of Echoreach have led countries into the future. Fighting them means they will find weaknesses you never knew you had, and they’ll destroy you with them.

            Bold | Creative | Unconventional
            """
        case .pulseforge:
            """
            Pulseforge members are driven by determination and passion that infects others. Always moving forward, their relentless pursuit of goals inspires everyone around them. They meet challenges head-on, energized by the thrill of pushing their limits. Pulseforge individuals don’t just chase success—they embody it through enthusiasm and force of will. Some Pulseforge members have won wars singlehandedly. Fighting one of them isn’t like fighting a person, but pure elemental force.

            Ambitious | Fiery | Determined
            """
        case .voidkind:
            """
            The Voidkind possess an understated intensity. They’re reserved yet observant. They carry an air of calm strength, communicating more through action than words. Beneath their quiet exterior lies a determination and depth that others rarely glimpse. When they act, it’s decisive and impactful, reflecting their consideration and passion. Some Voidkind members have destroyed empires from the shadows. Face them and they’ll strike fast and hard, often downing you with a single attack.
            
            Deep | Calculating | Mysterious
            """
        case .neurospire:
            """
            The minds of Neurospire are analytical, strategic, and sharp. They’re inquisitive, always seeking deeper understanding and clarity. Driven by a deep hunger, Neurospire individuals can’t help but pursue the secrets of the universe, and through that knowledge they often find power. Their strength lies in insight, precision, and an unwavering curiosity. Some of them are the architects of our world. Double cross those of the Neurospire and you likely lost before it even started.

            Perceptive | Innovative | Cerebral
            """
        }
    }
    
    var backgroundGradient: RadialGradient? {
        switch faction {
        case .echoreach:
            let bright = Color(red: 48/255, green: 128/255, blue: 54/255) // Green
            let dark = Color(red: 19/255, green: 55/255, blue: 47/255)
            return RadialGradient(colors: [bright, dark], center: .bottom, startRadius: 500, endRadius: 1000)
        case .pulseforge:
            let bright = Color(red: 139/255, green: 69/255, blue: 4/255) // Green
            let dark = Color(red: 104/255, green: 52/255, blue: 4/255)
            return RadialGradient(colors: [bright, dark], center: .center, startRadius: 100, endRadius: 500)
        case .voidkind:
            let bright = Color(red: 17/255, green: 17/255, blue: 60/255) // Green
            let dark = Color(red: 9/255, green: 9/255, blue: 30/255)
            return RadialGradient(colors: [bright, dark], center: .bottom, startRadius: 300, endRadius: 800)
        case .neurospire:
            return nil
        }
    }
    
    var body: some View {
        ZStack {
            // Background color based on faction
            if let backgroundGradient {
                backgroundGradient
                    .ignoresSafeArea()
            } else {
                Image("main_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    // Close button
                    HStack {
                        Button {
                            onDismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    // Content
                    VStack(spacing: 24) {
                        header
                        bodyView
                    }
                    
                    Spacer(minLength: 0)
                    
                    // Choose Faction Button
                    LUButton(title: "CHOOSE FACTION") {
                        onFactionSelected(faction)
                    }
                    .opacity(showContent ? 1.0 : 0.0)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 32)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
        }
    }
    
    var header: some View {
        VStack(spacing: 18) {
            VStack(spacing: 10) {
                Text("FACTION OVERVIEW")
                    .font(.mainFont(size: 20))
                    .bold()
                    .foregroundColor(.title)
                    .opacity(showContent ? 1.0 : 0.0)
                LUDivider()
                    .padding(.horizontal, 50)
            }
            // Faction Name
            Text(faction.name.uppercased())
                .font(.mainFont(size: 40))
                .bold()
                .foregroundColor(.textOrange)
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1.0 : 0.0)
            
            // Faction Icon
            Image(faction.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.textOrange)
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1.0 : 0.0)
        }
    }
    
    var bodyView: some View {
        VStack(spacing: 28) {
            Text(faction.description)
                .font(.system(size: 25))
                .foregroundColor(.white)
                .opacity(showContent ? 1.0 : 0.0)
            Text(bodyText)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(showContent ? 1.0 : 0.0)
        }
    }
}

#Preview {
    FactionDetailView(
        faction: .echoreach,
        onFactionSelected: { faction in
            print("Selected \(faction.name)")
        },
        onDismiss: {}
    )
    
    
}

#Preview {
    FactionDetailView(
        faction: .voidkind,
        onFactionSelected: { faction in
            print("Selected \(faction.name)")
        },
        onDismiss: {}
    )
    
    
}

#Preview {
    FactionDetailView(
        faction: .pulseforge,
        onFactionSelected: { faction in
            print("Selected \(faction.name)")
        },
        onDismiss: {}
    )
    
    
}

#Preview {
    FactionDetailView(
        faction: .neurospire,
        onFactionSelected: { faction in
            print("Selected \(faction.name)")
        },
        onDismiss: {}
    )
    
    
}
