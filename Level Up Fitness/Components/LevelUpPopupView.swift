//
//  LevelUpPopupView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/6/25.
//

import SwiftUI

struct LevelUpPopupView: View {
    let notification: LevelUpNotification
    let onDismiss: () -> Void
    
    @State private var showContent = false
    @State private var showUnlockedContent = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 24) {
                // Level Up Header
                VStack(spacing: 12) {
                    Text("LEVEL UP!")
                        .font(.mainFont(size: 32))
                        .bold()
                        .foregroundColor(.textOrange)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)
                    
                    HStack(spacing: 16) {
                        levelBadge(level: notification.fromLevel, isOld: true)
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                            .font(.title2)
                        
                        levelBadge(level: notification.toLevel, isOld: false)
                    }
                    .scaleEffect(showContent ? 1.0 : 0.8)
                    .opacity(showContent ? 1.0 : 0.0)
                }
                
                // Unlocked Content
                if !notification.unlockedContent.isEmpty {
                    VStack(spacing: 16) {
                        Text("New Content Unlocked!")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.textOrange)
                            .opacity(showUnlockedContent ? 1.0 : 0.0)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(notification.unlockedContent.enumerated()), id: \.offset) { index, content in
                                unlockedContentRow(content: content)
                                    .opacity(showUnlockedContent ? 1.0 : 0.0)
                                    .offset(y: showUnlockedContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1), value: showUnlockedContent)
                            }
                        }
                    }
                }
                
                // Dismiss Button
                LUButton(title: "Continue") {
                    onDismiss()
                }
                .opacity(showContent ? 1.0 : 0.0)
                .padding(.top, 8)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.major)
                    .shadow(color: .textOrange.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(showContent ? 1.0 : 0.9)
            .opacity(showContent ? 1.0 : 0.0)
            
            .padding(.horizontal)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showUnlockedContent = true
                }
            }
        }
    }
    
    private func levelBadge(level: Int, isOld: Bool) -> some View {
        VStack(spacing: 4) {
            Text("LEVEL")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isOld ? .gray : .white)
            Text("\(level)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(isOld ? .gray : .textOrange)
            
            
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isOld ? Color.gray.opacity(0.3) : Color.textOrange.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isOld ? Color.gray : Color.textOrange, lineWidth: 2)
                )
        )
    }
    
    private func unlockedContentRow(content: UnlockableContent) -> some View {
        HStack(spacing: 12) {
            Image(content.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 35, height: 35)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(content.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(content.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.textfieldBg.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.textfieldBorder, lineWidth: 1)
                )
        )
    }
}

#Preview {
    LevelUpPopupView(
        notification: LevelUpNotification(
            fromLevel: 4,
            toLevel: 5,
            unlockedContent: [.missions, .factions, .factionLeaderboards, .paths]
        ),
        onDismiss: {}
    )
}
