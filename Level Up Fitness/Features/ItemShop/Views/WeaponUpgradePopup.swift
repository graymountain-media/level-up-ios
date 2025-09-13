//
//  WeaponUpgradePopup.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 8/8/25.
//

import SwiftUI

struct WeaponUpgradePopup: View {
    let item: Item
    let onDismiss: () -> Void
    
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Dark overlay background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                VStack(spacing: 20) {
                    // Main content
                    VStack(spacing: 30) {
                        Text("\(item.itemSlot.displayName.uppercased())\nUPGRADED!")
                            .font(.mainFont(size: 40))
                            .bold()
                            .foregroundStyle(.title)
                            .multilineTextAlignment(.center)
                        
                        // Item icon with border
                        ItemSlotView(itemSlot: item.itemSlot, item: item)
                        .frame(width: 100, height: 100)
                        
                        // XP Bonus
                        Text("\(item.formattedXPBonus) BONUS")
                            .font(.mainFont(size: 30))
                            .bold()
                            .foregroundStyle(.textOrange)
                        
                        // Description
                        VStack(spacing: 16) {
                            Text("You will now earn a bonus of \(item.formattedXPBonus) on every workout you perform.")
                            Text("View your Home page to see item equipped to your Avatar!")
                                
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.textDetail)
                        .multilineTextAlignment(.center)
                        .italic()
                        .padding(.horizontal, 40)
                        LUButton(title: "Continue") {
                            dismissWithAnimation()
                        }
                    }
                    
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.major)
                )
                
                    Spacer()
            }
            .opacity(showContent ? 1 : 0)
            .scaleEffect(showContent ? 1 : 0.8)
            .padding(.horizontal)
        }
        .mainBackground()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                showContent = true
            }
        }
        .onTapGesture {
            dismissWithAnimation()
        }
    }
    
    private func dismissWithAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showContent = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

#Preview {
    WeaponUpgradePopup(
        item: Item(
            id: UUID(),
            name: "Ion Handgun",
            description: "A compact firearm capable of disrupting light armor and electronic shielding.",
            xpBonus: 4.5,
            price: 84,
            itemSlot: .weapon,
            requiredPaths: [.ranger, .hunter, .strider],
            requiredLevel: 5
        ),
        onDismiss: {}
    )
}
