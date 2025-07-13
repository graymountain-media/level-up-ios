//
//  SlideOutMenu.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/2/25.
//

import SwiftUI

struct SlideOutMenu: View {
    @Environment(AppState.self) var appState
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
                            ForEach(Destination.allCases) { item in
                                menuButton(for: item)
                                
                                if [.missionBoard, .leaderboard].contains(item) {
                                    Divider()
                                        .background(Color.white)
                                        .padding(.vertical, 8)
                                }
                                Button("Sign Out") {
                                    Task {
                                        let _ = try? await
                                        appState.supabaseService.signOut()
                                    }
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
    
    func menuButton(for destination: Destination) -> some View {
        Button(action: {
            if destination != .avatar {
                appState.presentedDestination = destination
            }
            withAnimation {
                appState.isShowingMenu = false
            }
        }) {
            HStack(spacing: 16) {
                Image(destination.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                Text(destination.title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    SlideOutMenu()
}
