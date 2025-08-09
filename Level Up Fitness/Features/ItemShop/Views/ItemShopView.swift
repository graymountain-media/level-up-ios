//
//  ItemShopView.swift
//  Level Up
//
//  Created by Jake Gray on 8/8/25.
//

import SwiftUI
import FactoryKit

struct ItemShopView: View {
    @InjectedObservable(\.appState) var appState
    @Injected(\.itemService) var itemService
    
    @State private var selectedTab: ItemSlot = .weapon
    @State private var availableItems: [Item] = []
    @State private var userInventory: UserInventory?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var purchasingItemId: UUID?
    @State private var equippingItemId: UUID?
    @State private var showWeaponUpgradePopup: Item?
    
    var body: some View {
        VStack(spacing: 25) {
            VStack {
                FeatureHeader(title: "Item Shop", showCloseButton: true)
                    .padding(.horizontal)
                
                tabSelector
            
            }
            HStack {
                Spacer()
                Text("Gold: \(appState.userAccountData?.profile.credits ?? 0)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.goldDark)
                Image("gold_icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 24)
                Spacer()
            }
            .padding(.horizontal)
            if isLoading {
                Spacer()
                ProgressView("Loading items...")
                    .padding()
                Spacer()
            } else if let errorMessage = errorMessage {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                        .padding(.horizontal, 40)
                    Button("Retry") {
                        Task { await loadItems() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                Spacer()
            } else {
                items
            }
        }
        .padding(.bottom, 32)
        .mainBackground()
        .task {
            await loadData()
        }
        .overlay {
            // Weapon upgrade popup
            if let upgradeItem = showWeaponUpgradePopup {
                WeaponUpgradePopup(item: upgradeItem) {
                    showWeaponUpgradePopup = nil
                }
                .transition(.opacity)
            }
        }
    }
    
    var items: some View {
        GeometryReader { geometry in
            let filteredItems = availableItems.filter { $0.itemSlot == selectedTab }
            
            if filteredItems.isEmpty {
                VStack {
                    Spacer()
                    Text("No \(selectedTab.displayName.lowercased())s available")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                    Text("Check back later for new items!")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 24) {
                            ForEach(filteredItems) { item in
                                card(item: item, geometry: geometry)
                                    .id(item.id)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal, 75)
                    .onAppear {
                        scrollToFirstBuyableItem(in: filteredItems) { id in
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                    .onChange(of: selectedTab) { _, _ in
                        let newFilteredItems = availableItems.filter { $0.itemSlot == selectedTab }
                        scrollToFirstBuyableItem(in: newFilteredItems) { id in
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
            }
        }
    }
    
    func card(item: Item, geometry: GeometryProxy) -> some View {
        let userOwnsItem = userInventory?.owns(itemId: item.id) ?? false
        let itemIsEquipped = userInventory?.isEquipped(itemId: item.id) ?? false
        let canUseItem = item.isCompatibleWith(path: appState.userAccountData?.profile.path)
        let hasEnoughCredits = (appState.userAccountData?.profile.credits ?? 0) >= item.price
        let currentlyEquippedItem = userInventory?.equippedItem(for: item.itemSlot)
        let isUpgrade = currentlyEquippedItem?.item?.xpBonus ?? 0 < item.xpBonus
        let userLevel = appState.userAccountData?.currentLevel ?? 0
        let meetsLevelRequirement = item.meetsLevelRequirement(userLevel: userLevel)
        
        return VStack {
            VStack(spacing: 20) {
                VStack(spacing: 14) {
                    // Level requirement display
                    Text("Level \(item.requiredLevel)")
                        .font(.mainFont(size: 17))
                        .foregroundStyle(meetsLevelRequirement ? .title : .red)
                        .bold()
                    
                    // Item image placeholder
                    Image(item.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 115, height: 115)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Path requirement display
                    if !item.requiredPaths.isEmpty {
                        pathRequirementText(item: item, canUseItem: canUseItem)
                    }
                    
                    // Item title
                    Text(item.name.uppercased())
                        .font(.mainFont(size: 20))
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.textOrange)
                    
                    // Item description
                    Text(item.description)
                        .font(.system(size: 14))
                        .foregroundStyle(.textDetail)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        // Item price
                        HStack(spacing: 4) {
                            Text("\(item.price)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Image("gold_icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                        }
                        .frame(height: 36)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.gray.opacity(0.3))
                        )
                        
                        // Item XP boost
                        HStack(spacing: 4) {
                            Text(item.shortXP)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            Image("xp_icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                        }
                        .frame(height: 36)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.gray.opacity(0.3))
                        )
                    }
                }
                
                // Action button
                actionButton(for: item, userOwnsItem: userOwnsItem, itemIsEquipped: itemIsEquipped, canUseItem: canUseItem, hasEnoughCredits: hasEnoughCredits, isUpgrade: isUpgrade, meetsLevelRequirement: meetsLevelRequirement)
            }
            .padding(24)
            .frame(width: geometry.size.width - 150)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.textfieldBg)
            )
            Spacer()
        }
    }
    
    @ViewBuilder
    private func actionButton(for item: Item, userOwnsItem: Bool, itemIsEquipped: Bool, canUseItem: Bool, hasEnoughCredits: Bool, isUpgrade: Bool, meetsLevelRequirement: Bool) -> some View {
        if !meetsLevelRequirement {
            Text("Level \(item.requiredLevel) Required")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.red)
                .frame(height: 44)
        } else if !canUseItem && !userOwnsItem {
            Text("Path Required")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.red)
                .frame(height: 44)
        } else if itemIsEquipped {
            Text("Equipped")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textOrange)
                .frame(height: 44)
        } else if userOwnsItem && !isUpgrade {
            Text("Purchased")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .frame(height: 44)
        } else if userOwnsItem && isUpgrade {
            LUButton(title: "Equip", isLoading: equippingItemId == item.id, fillSpace: false, size: .small) {
                Task {
                    await equipItem(item)
                }
            }
            .disabled(equippingItemId == item.id)
        } else if !isUpgrade && !userOwnsItem {
            Text("Lower Stats")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .frame(height: 44)
        } else if hasEnoughCredits && isUpgrade {
            LUButton(title: "Buy", isLoading: purchasingItemId == item.id, fillSpace: false, size: .small) {
                Task {
                    await purchaseItem(item)
                }
            }
            .disabled(purchasingItemId == item.id)
        } else {
            Text("Insufficient Credits")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.red)
                .frame(height: 44)
        }
    }
    
    var tabSelector: some View {
        return HStack(spacing: 8) {
            ForEach(ItemSlot.allCases, id: \.rawValue) { tab in
                let isDisabled = tab != .weapon
                
                Button(action: {
                    guard !isDisabled else { return }
                    selectedTab = tab
                }) {
                    Text(tab.rawValue.capitalized)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isDisabled ? .gray : .white)
                        .frame(height: 36)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    isDisabled ? Color.gray.opacity(0.6) :
                                    selectedTab == tab ? Color.textInput : Color.textfieldBorder
                                )
                        )
                }
                .disabled(isDisabled)
            }
        }
        .padding(.horizontal, 48)
    }
    
    @ViewBuilder
    private func pathRequirementText(item: Item, canUseItem: Bool) -> some View {
        let userPath = appState.userAccountData?.profile.path
        let pathTexts = item.requiredPaths.map { path in
            if path == userPath {
                Text(path.name).foregroundColor(.green)
            } else {
                Text(path.name).foregroundColor(.white)
            }
        }
        
        HStack(spacing:0) {
            ForEach(0..<pathTexts.count, id: \.self) { index in
                pathTexts[index]
                if index < pathTexts.count - 1 {
                    Text(", ").foregroundColor(.white)
                }
            }
        }
        .font(.system(size: 14))
        .italic()
    }
    
    // MARK: - Scroll Helpers
    
    private func scrollToFirstBuyableItem(in items: [Item], scrollTo: @escaping (UUID) -> Void) {
        guard let userInventory = userInventory else { return }
        
        // Find the first item that is either:
        // 1. An upgrade they can buy
        // 2. An upgrade they own but haven't equipped
        // 3. The currently equipped item (if no upgrades available)
        let firstBuyableItem = items.first { item in
            let userOwnsItem = userInventory.owns(itemId: item.id)
            let itemIsEquipped = userInventory.isEquipped(itemId: item.id)
            let canUseItem = item.isCompatibleWith(path: appState.userAccountData?.profile.path)
            let hasEnoughCredits = (appState.userAccountData?.profile.credits ?? 0) >= item.price
            let currentlyEquippedItem = userInventory.equippedItem(for: item.itemSlot)
            let isUpgrade = currentlyEquippedItem?.item?.xpBonus ?? 0 < item.xpBonus
            let userLevel = appState.userAccountData?.currentLevel ?? 0
            let meetsLevelRequirement = item.meetsLevelRequirement(userLevel: userLevel)
            
            // Return true if this item is actionable (buyable or equippable)
            if itemIsEquipped {
                return true // Currently equipped item
            } else if userOwnsItem && isUpgrade && meetsLevelRequirement {
                return true // Owned upgrade ready to equip
            } else if !userOwnsItem && isUpgrade && canUseItem && hasEnoughCredits && meetsLevelRequirement {
                return true // Buyable upgrade
            }
            return false
        }
        
        // If we found a buyable item, scroll to it with animation
        if let targetItem = firstBuyableItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    scrollTo(targetItem.id)
                }
            }
        }
    }
    
    // MARK: - Data Loading
    
    private func loadData() async {
        await loadItems()
        await loadUserInventory()
    }
    
    private func loadItems() async {
        isLoading = true
        errorMessage = nil
        
        do {
            availableItems = try await itemService.fetchAllItems()
        } catch {
            errorMessage = "Failed to load items: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func loadUserInventory() async {
        do {
            userInventory = try await itemService.fetchUserInventory()
        } catch {
            print("Failed to load user inventory: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Item Actions
    
    private func purchaseItem(_ item: Item) async {
        purchasingItemId = item.id
        
        do {
            // Purchase and auto-equip the item
            try await itemService.purchaseAndEquipItem(item.id)
            await MainActor.run {
                showWeaponUpgradePopup = item
            }
            await appState.refreshUserData() // Refresh to update credits
            await loadUserInventory() // Refresh inventory
            
            // Show the upgrade popup
        } catch {
            errorMessage = "Failed to purchase item: \(error.localizedDescription)"
        }
        
        purchasingItemId = nil
    }
    
    private func equipItem(_ item: Item) async {
        equippingItemId = item.id
        
        do {
            try await itemService.equipItem(item.id)
            await loadUserInventory() // Refresh inventory
        } catch {
            errorMessage = "Failed to equip item: \(error.localizedDescription)"
        }
        
        equippingItemId = nil
    }
    
    private func unequipItem(_ item: Item) async {
        equippingItemId = item.id
        
        do {
            try await itemService.unequipItem(slot: item.itemSlot)
            await loadUserInventory() // Refresh inventory
        } catch {
            errorMessage = "Failed to unequip item: \(error.localizedDescription)"
        }
        
        equippingItemId = nil
    }
}

#Preview {
    let _ = Container.shared.setupMocks()
    ItemShopView()
}
