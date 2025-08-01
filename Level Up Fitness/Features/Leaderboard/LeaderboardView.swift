//
//  LeaderboardView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/4/25.
//

import SwiftUI
import Supabase
import FactoryKit

// MARK: - Models
enum LeaderboardTab: String, CaseIterable {
    case xp = "XP"
    case streaks = "Streaks"
    case factions = "Factions"
}

struct LeaderboardView: View {
    // MARK: - Properties
    @State private var viewModel = LeaderboardViewModel()
    @State private var selectedTab: LeaderboardTab = .xp
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            FeatureHeader(title: "Leaderboard")
            // Tab selector
            tabSelector
            
            // Content
            VStack(spacing: 24) {
                // XP Leaders header
                header
                
                // Content based on loading state
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage: errorMessage)
                } else {
                    leaderboardContent
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 42)
        }
        .background(
            Image("main_bg")
                .resizable()
                .ignoresSafeArea()
        )
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { viewModel.showError = false }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .task {
            await viewModel.fetchLeaderboard(for: selectedTab)
        }
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        let tabs = LeaderboardTab.allCases.filter({ $0 != .factions })
        return HStack(spacing: 4) {
            ForEach(tabs, id: \.rawValue) { tab in
                Button(action: {
                    selectedTab = tab
                    Task {
                        await viewModel.fetchLeaderboard(for: selectedTab)
                    }
                }) {
                    Text(tab.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .frame(height: 27)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    selectedTab == tab ? Color.textInput : Color.textfieldBorder
                                    )
                            
                        )
                }
            }
        }
        .padding(.horizontal, 48)
        
    }
    
    // MARK: - XP Leaders Header
    private var header: some View {
        var imageName: String? {
            switch selectedTab {
            case .xp:
                "xp_orb"
            case .streaks:
                "streak_flame"
            case .factions:
                nil
            }
        }
        var title: String {
            switch selectedTab {
            case .xp:
                "XP LEADERS"
            case .streaks:
                "STREAK LEADERS"
            case .factions:
                "FACTION WARS"
            }
        }
        var textColor: Color {
            switch selectedTab {
            case .xp:
                .cyan
            case .streaks:
                .textOrange
            case .factions:
                .textDetail
            }
        }
        return VStack {
            HStack(spacing: 12) {
                Spacer()
                if let imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        
                }
                
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(textColor)
                
                Spacer()
            }
            .italic()
            .frame(height: 40)
            Rectangle()
                .foregroundStyle(.white.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, 60)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.cyan))
                .scaleEffect(1.5)
            
            Text("Loading leaderboard...")
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 100)
    }
    
    // MARK: - Error View
    private func errorView(errorMessage: String) -> some View {
        VStack(spacing: 20) {
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
                    await viewModel.fetchLeaderboard(for: selectedTab)
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
        }
    }
    
    // MARK: - Leaderboard Content
    private var leaderboardContent: some View {
        ScrollView {
            VStack(spacing: 12) {
                if viewModel.leaderboardEntries.isEmpty {
                    Text("No leaderboard data available")
                        .foregroundColor(.gray)
                        .padding(.vertical, 40)
                } else {
                    ForEach(Array(viewModel.leaderboardEntries.enumerated()), id: \.element.id) { index, entry in
                        leaderboardEntryRow(entry: entry, rank: Int(entry.rank))
                    }
                }
            }
        }
    }
    
    // MARK: - Leaderboard Entry Row
    private func leaderboardEntryRow(entry: any LeaderboardEntry, rank: Int) -> some View {
        func getRankDisplay(_ rank: Int) -> String {
            switch rank {
            case 1: return "1st"
            case 2: return "2nd"
            case 3: return "3rd"
            default: return "\(rank)th"
            }
        }
        
        var rankColor: Color {
            switch selectedTab {
            case .xp:
                .cyan
            case .streaks:
                .textOrange
            case .factions:
                .textDetail
            }
        }
        return HStack(alignment: .bottom, spacing: 16) {
            // Rank
            Text("\(getRankDisplay(rank))")
                .font(.system(size: 13))
                .foregroundColor(rankColor)
                .padding(.bottom, 12)
                .frame(width: 32)
            
            // Avatar
            AsyncImage(url: URL(string: "https://via.placeholder.com/60x60")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image("profile_placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .frame(width: 52, height: 52)
            
            VStack {
                HStack {
                    // Name and Class
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.avatarName?.uppercased() ?? "UNKNOWN")
                            .font(.mainFont(size: 17.5))
                            .bold()
                            .foregroundColor(.title)
                        
//                        Text(getClassForEntry(entry))
//                            .font(.system(size: 12))
//                            .foregroundColor(.cyan)
//                            .italic()
                    }
                    
                    Spacer(minLength: 8)
                    
                    Text(formatScore(entry.value))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(rankColor)
                }
                Rectangle()
                    .fill(.white.opacity(0.1))
                    .frame(height: 1)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func getClassForEntry(_ entry: LeaderboardEntry) -> String {
        // Map entry data to class names that match the image
        let classes = ["Neurospire", "Pulseforge", "Echoreach", "Voidling"]
        return classes.randomElement() ?? "Neurospire"
    }
    
    private func formatScore(_ score: Int) -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: score), number: .decimal)
    }
}

#Preview {
    let _ = Container.shared.setupMocks()
    LeaderboardView()
}
