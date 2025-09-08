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
            await viewModel.loadInitialData()
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
                    FactionMembersView(factionMembers: viewModel.factionMembers)
                case .strongholds:
                    FactionStrongholdsView()
                }
            }
        } else {
            // Handle error state
            errorView(errorMessage: "Failed to load faction data.")
        }
    }
    
    private func errorView(errorMessage: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.cyan)
            
            Text("Error")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.cyan)
            
            Text(errorMessage)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {
                Task {
                    await viewModel.loadInitialData()
                }
            }) {
                Text("Retry")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.cyan)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
    
}


#Preview {
    let _ = Container.shared.setupMocks()
    FactionHomeView()
}
