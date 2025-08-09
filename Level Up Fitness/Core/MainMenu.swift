//
//  MainMenu.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/2/25.
//

import SwiftUI
import FactoryKit

enum MenuItem: Int, CaseIterable, Identifiable {
    case itemShop
    case accountSettings
    case help
    
    var id: Int {
        return self.rawValue
    }
    
    var imageName: String {
        switch self {
        case .itemShop:
            "store_icon"
        case .accountSettings:
            "settings_icon"
        case .help:
            "help_icon"
        }
    }
    
    var title: String {
        switch self {
        case .itemShop:
            "Item Shop"
        case .accountSettings:
            "Account Settings"
        case .help:
            "Help Center"
        }
    }
}

struct MainMenu: View {
    @InjectedObservable(\.appState) var appState
    var body: some View {
        ZStack {
            if appState.isShowingMenu {
                Color.black.opacity(0.5)
                                .ignoresSafeArea()
                                .transition(.opacity)
                                .onTapGesture {
                                    appState.isShowingMenu.toggle()
                                }
                GeometryReader { proxy in
                    VStack(alignment: .leading, spacing: 0) {
                        // App Logo
                        HStack {
                            Image("logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            Button {
                                appState.isShowingMenu.toggle()
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(Color.minor)
                            }
                            
                        }
                        .padding(.trailing, 24)
                            
                        
                        // Menu Items
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(MenuItem.allCases) { feature in
                                menuButton(for: feature)
                                
                                if [.accountSettings].contains(feature) {
                                    Divider()
                                        .background(Color.white)
                                        .padding(.vertical, 8)
                                }
                                
                            }
                            Spacer()
                            LUButton(title: "Sign Out", fillSpace: true) {
                                Task {
                                    let _ = await
                                    appState.userDataService.signOut()
                                    let tipManager = SequentialTipsManager(tips: [], storageKey: "temp")
                                    tipManager.resetTips()
                                    appState.currentTab = .home
                                    appState.isShowingMenu = false
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 16)
                        
                        Spacer()
                    }
                    .background(Color.major)
                    .frame(width: proxy.size.width * 0.7)
                    
                }.transition(
                    .asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .leading)
                    )
                ).zIndex(1)
            }
        }
        .animation(.easeInOut, value: appState.isShowingMenu)
    }
    
    func menuButton(for item: MenuItem) -> some View {
        Button(action: {
            if item == .help {
                withAnimation {
                    appState.isShowingHelp = true
                }
            } else {
                appState.setMenuItem(item)
            }
            withAnimation {
                appState.isShowingMenu = false
            }
        }) {
            HStack(spacing: 16) {
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                Text(item.title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    
    var appState: AppState {
        let appState = AppState()
        appState.isShowingMenu = true
        return appState
    }
    MainMenu()
        .environment(appState)
}
