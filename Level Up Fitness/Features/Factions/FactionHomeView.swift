//
//  FactionHomeView.swift
//  Level Up
//
//  Created by Sam Smith on 8/29/25.
//

import SwiftUI
import FactoryKit

struct FactionHomeView: View {
    
    @State private var viewModel = FactionHomeViewModel()
    
    var body: some View {
        VStack(spacing: 25) {
            VStack {
                FeatureHeader(title: "Faction", showCloseButton: true)
                    .padding(.horizontal)
                
                tabSelector
                    .padding(.bottom, 12)
                
                mainContent
            }
        }
        .padding(.bottom, 32)
        .factionBackground(faction: viewModel.factionDetails?.faction)
        .task {
            await viewModel.fetchFactionDetails()
        }
    }
    
    private var tabSelector: some View {
        return HStack(spacing: 4) {
            ForEach(FactionTabs.allCases) { tab in
                let isDisabled = tab == .strongholds

                Button(action: {
                    guard !isDisabled else { return }
                    viewModel.selectedTab = tab
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
                                    viewModel.selectedTab == tab ? Color.textInput : Color.textfieldBorder
                                )
                        )
                }
                .disabled(isDisabled)
            }
        }
        .padding(.horizontal, 48)
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if viewModel.isLoading {
            ProgressView("Loading faction information...")
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let factionDetails = viewModel.factionDetails {
            ScrollView {
                switch viewModel.selectedTab {
                case .overview:
                    FactionOverviewView(factionDetails: factionDetails)
                case .members:
                    FactionMembersView()
                case .strongholds:
                    FactionStrongholdsView()
                }
            }
        } else {
            // Handle error state
            Text("Failed to load faction data.")
        }
    }
    
}


#Preview {
    let _ = Container.shared.setupMocks()
    FactionHomeView()
}
