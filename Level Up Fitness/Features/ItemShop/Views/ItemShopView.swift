//
//  ItemShopView.swift
//  Level Up
//
//  Created by Jake Gray on 8/8/25.
//

import SwiftUI
import FactoryKit

struct ItemShopView: View {
    @State var selectedTab: ItemSlot = .weapon
    var body: some View {
        VStack(spacing: 50) {
            VStack {
                FeatureHeader(title: "Item Shop", showCloseButton: true)
                    .padding(.horizontal)
                tabSelector
            }
            items
        }
        .padding(.bottom, 32)
        .mainBackground()
        
    }
    
    var items: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 24) {
                    ForEach(0..<10) { i in
                        card(geometry: geometry)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, 75)
        }
    }
    
    func card(geometry: GeometryProxy) -> some View {
        VStack {
            VStack(spacing: 20) {
                VStack(spacing: 14) {
                    Text("Level 12")
                        .font(.mainFont(size: 17))
                        .foregroundStyle(.title)
                        .bold()
                    Image("test_gloves")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 14)
                    Text("Brute, Hunter, Juggernaut")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .italic()
                    Text("PRESSOR FISTS")
                        .font(.mainFont(size: 20))
                        .bold()
                        .foregroundStyle(.textOrange)
                    Text("""
                        Exo-gloves amplifying grip and crushing power.
                        Perfect for hand-to-hand in confined environments.
                        """
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(.textDetail)
                    HStack {
                        HStack {
                            Text("100")
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
                                .fill(
                                    .gray.opacity(0.3))
                        )
                        HStack {
                            Text("9%")
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
                                .fill(
                                    .gray.opacity(0.3))
                        )
                    }
                }
                LUButton(title: "Buy", isLoading: false, fillSpace: false, size: .small) {
                    
                }
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
    
    var tabSelector: some View {
        return HStack(spacing: 8) {
            ForEach(ItemSlot.allCases, id: \.rawValue) { tab in
                let isDisabled = tab != .weapon
                
                Button(action: {
                    guard !isDisabled else { return }
                    selectedTab = tab
                    // TODO: Get items for slot
                }) {
                    Text(tab.rawValue.capitalized)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isDisabled ? .gray : .white)
                        .frame(height: 36)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    isDisabled ? Color.textfieldBorder.opacity(0.3) :
                                    selectedTab == tab ? Color.textInput : Color.textfieldBorder
                                )
                        )
                }
                .disabled(isDisabled)
                .opacity(isDisabled ? 0.5 : 1.0)
            }
        }
        .padding(.horizontal, 48)
    }
}

#Preview {
    let _ = Container.shared.setupMocks()
    ItemShopView()
}
