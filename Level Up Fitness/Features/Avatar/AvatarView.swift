//
//  AvatarView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/1/25.
//

import SwiftUI
import FactoryKit
import TipKit
import CachedAsyncImage

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
    var manager: SequentialTipsManager
    var mainNamespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 0) {
            if appState.isLoadingUserData {
                loadingView
            } else {
                heroInfo
                    .onAppear {
                        manager.startTips()
                    }
            }
        }
        .onAppear {
            print("DATA SERVICE: \(type(of: appState.userDataService))")
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
        ZStack {
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
                        .tipSource(id: 1, nameSpace: mainNamespace, manager: manager, anchorPoint: .bottom)
                        .tipSource(id: 2, nameSpace: mainNamespace, manager: manager, anchorPoint: .bottom )
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
                    
                    streakView
                    
                    
                }
                .padding(.horizontal, 40)
                .foregroundStyle(.white)
                Spacer(minLength: 12)
                CachedAsyncImage(url: URL(string: appState.userAccountData?.profile.avatarUrl ?? "")) { image in
                    EquatableView(id: 3) {
                        image
                            .resizable()
                            .aspectRatio(4/5, contentMode: .fit)
                            .id(1)
                    }
                    .equatableTipSource(id: 3, nameSpace: mainNamespace, manager: manager)
                } placeholder: {
                    EquatableView(id: 4) {
                        Image("avatar_placeholder")
                            .resizable()
                            .aspectRatio(4/5, contentMode: .fit)
                            .opacity(0.5)
                    }
                    .equatableTipSource(id: 3, nameSpace: mainNamespace, manager: manager)
                }
            }
            .padding(.top, 32)
            VStack(alignment: .trailing) {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 2) {
                        WeaponSlotView(item: appState.userInventory?.equippedItem(for: .weapon)?.item)
                            .frame(width: 90, height: 90)
                        if let xpBonus = appState.userInventory?.equippedItem(for: .weapon)?.item?.formattedXPBonus {
                            Text(xpBonus)
                                .font(.mainFont(size: 14))
                                .bold()
                                .foregroundStyle(.white)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .onTapGesture {
                appState.selectedMenuItem = .itemShop
            }
        }
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
    
    var streakView: some View {
        let streak = appState.userAccountData?.currentStreak ?? 0
        let dayText = streak == 1 ? "day" : "days"
        return VStack(alignment: .trailing) {
            HStack {
                Text("Streak:")
                    .bold()
                    .foregroundStyle(.white)
                Text("\(streak) \(dayText)")
                    .foregroundStyle(.white)
                Spacer()
            }
        }
        .tipSource(id: 4, nameSpace: mainNamespace, manager: manager, anchorPoint: .bottom)
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

struct EquatableView<I: View>: View, Equatable {
    var image: I
    var id: Int
    
    init(id: Int, @ViewBuilder image: () -> I) {
        self.id = id
        self.image = image()
    }
    
    var body: some View {
        image
    }
    
    static func == (lhs: EquatableView, rhs: EquatableView) -> Bool {
        return lhs.id == rhs.id
    }
}

#Preview {
    @Previewable @Namespace var namespace
    let _ = Container.shared.setupMocks()
    AvatarView(manager: .avatarTips(), mainNamespace: namespace)
}

struct ViewHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
