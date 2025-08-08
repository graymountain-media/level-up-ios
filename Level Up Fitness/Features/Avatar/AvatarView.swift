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
    var mainNamespace: Namespace.ID
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
    
    @State private var nameHeight: CGFloat = 0
    @State private var pathHeight: CGFloat = 0
    var heroInfo: some View {
        VStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 4) {
                    avatarNameView
                        .layoutPriority(2)
                    Spacer(minLength: 4)
                    pathView
                        .layoutPriority(1)
                }
                .frame(maxWidth: .infinity)
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
                .zIndex(-11)
                
                VStack(alignment: .trailing) {
                    HStack {
                        Text("Streak:")
                            .bold()
                            .foregroundStyle(.white)
                        Text("\(appState.userAccountData?.currentStreak ?? 0) days")
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
                .tipSource(id: 3, nameSpace: namespace, manager: manager, anchorPoint: .bottom)
                
                
            }
            .padding(.horizontal, 40)
            .foregroundStyle(.white)
            Spacer(minLength: 12)
            AsyncImage(url: URL(string: appState.userAccountData?.profile.avatarUrl ?? "")) { image in
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
        }
        .padding(.top, 32)
    }
    
    var avatarNameView: some View {
        HStack(spacing: 4) {
            Text(appState.userAccountData?.avatarName ?? "Unknown")
                .font(.mainFont(size: 38))
                .bold()
                .lineLimit(1)
                .foregroundStyle(.textOrange)
                .minimumScaleFactor(0.8)
                .shadow(radius: 4, y: 4)
            if let faction = appState.userAccountData?.profile.faction {
                Image(faction.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(maxHeight: 42)
    }
    
    @ViewBuilder
    var pathView: some View {
        if let path = appState.userAccountData?.profile.path {
            HStack(spacing: 4) {
                Image(path.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .matchedGeometryEffect(id: "pathIcon", in: mainNamespace)
                    .frame(maxHeight: .infinity)
                    .zIndex(10)
                Text(path.name.uppercased())
                    .font(.system(size: 18))
                
                .minimumScaleFactor(0.5)
                    .foregroundStyle(.textPath)
                    .matchedGeometryEffect(id: "pathName", in: mainNamespace)
                    .lineLimit(1)
            }
            .frame(minHeight: 10, maxHeight: 26)
        }
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
    @Previewable @Namespace var namespace
    let _ = Container.shared.setupMocks()
    AvatarView(mainNamespace: namespace)
}

struct ViewHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
