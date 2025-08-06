//
//  AvatarView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI
import FactoryKit
import TipKit

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
    @InjectedObservable(\.appState) var appState
    @State var manager = SequentialTipsManager.avatarTips()
    @Namespace var namespace
    var body: some View {
        VStack(spacing: 0) {
            if appState.isLoadingUserData {
                loadingView
            } else {
                heroInfo
                    .onAppear {
                        manager.startTips()
                    }
                    .tipOverlay(namespace: namespace, manager: manager)
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("citiscape")
                .resizable()
                .ignoresSafeArea()
                .allowsHitTesting(false)
        )
        .task {
            // Load user data if not already loaded
            if appState.userAccountData == nil && appState.isAuthenticated {
                await appState.loadUserData()
            }
        }
    }
    
    var heroInfo: some View {
        VStack {
            VStack(alignment: .center, spacing: 16) {
                HStack {
                    Text(appState.userAccountData?.avatarName ?? "Unknown")
                        .font(.mainFont(size: 38))
                        .bold()
                        .foregroundStyle(.textOrange)
                        .shadow(radius: 4, y: 4)
                    if let faction = appState.userAccountData?.profile.faction {
                        Image(faction.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 45, height: 45)
                    }
                    Spacer()
                }
                ProgressBar()
                    .tipSource(id: 0, nameSpace: namespace, manager: manager, anchorPoint: .bottom)
                    .tipSource(id: 1, nameSpace: namespace, manager: manager, anchorPoint: .bottom )
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.textfieldBg.opacity(0.5))
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.textfieldBorder, lineWidth: 4)
                    }
                )
                .padding(.horizontal, -16)
                
                VStack(alignment: .trailing) {
                    HStack {
                        Text("Streak:")
                            .bold()
                        Text("\(appState.userAccountData?.currentStreak ?? 0) days")
                            .foregroundStyle(.white)
                        Image("fire-icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                        Spacer()
                    }
                }
                .tipSource(id: 3, nameSpace: namespace, manager: manager, anchorPoint: .bottom)
                
                
            }
            .padding(.horizontal, 40)
            .foregroundStyle(.white)
            Spacer(minLength: 12)
            if let avatarUrl = appState.userAccountData?.profile.avatarUrl {
                AsyncImage(url: URL(string: avatarUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(4/5, contentMode: .fit)
                        .tipSource(id: 2, nameSpace: namespace, manager: manager)
                } placeholder: {
                    Image("avatar_placeholder")
                        .resizable()
                        .aspectRatio(4/5, contentMode: .fit)
                        .opacity(0.5)
                }
            } else {
                Image("avatar_placeholder")
                    .resizable()
                    .aspectRatio(4/5, contentMode: .fit)
                    .opacity(0.5)
                    .tipSource(id: 2, nameSpace: namespace, manager: manager)
            }
        }
        .padding(.top, 32)
    }
    
    var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .scaleEffect(1.5)
            
            Text("Loading avatar data...")
                .foregroundColor(.white)
                .font(.headline)
        }
        .padding(.top, 100)
    }
    
    var avatarView: some View {
        VStack {
            Spacer()
                    }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                Color.black.ignoresSafeArea()
                    .allowsHitTesting(false)
                Image("citiscape")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    let _ = Container.shared.setupMocks()
    AvatarView()
}
