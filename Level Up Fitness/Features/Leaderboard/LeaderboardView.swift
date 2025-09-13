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
    @State private var selectedEntry: (any LeaderboardEntry)?
    
    @InjectedObservable(\.appState) var appState
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            FeatureHeader(title: "Leaderboard")
            // Tab selector
            tabSelector
            
            // Content
            VStack(spacing: 0) {
                // XP Leaders header
                header
                    .padding(.bottom, 24)
                
                // Content based on loading state
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage: errorMessage)
                } else {
                    leaderboardContent
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 42)
        }
        .mainBackground()
        .overlay (
            Group {
                if let selectedEntry {
                    UserInfoPopup(
                        userId: selectedEntry.userId,
                        viewProfile: {
                            // Handle view profile action
                            withAnimation {
                                self.selectedEntry = nil
                            }
                        },
                        dismiss: {
                            withAnimation {
                                self.selectedEntry = nil
                            }
                        }
                    )
                }
            }
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
        let userLevel = appState.userAccountData?.currentLevel ?? 1
        let isFactionUnlocked = userLevel >= 3
        
        return HStack(spacing: 4) {
            ForEach(LeaderboardTab.allCases, id: \.rawValue) { tab in
                let isDisabled = tab == .factions && !isFactionUnlocked
                
                Button(action: {
                    guard !isDisabled else { return }
                    selectedTab = tab
                    Task {
                        await viewModel.fetchLeaderboard(for: selectedTab)
                    }
                }) {
                    Text(tab.rawValue)
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
                        if selectedTab == .factions, let factionEntry = entry as? FactionLeaderboardEntry {
                            factionLeaderboardRow(entry: factionEntry, rank: Int(entry.rank))
                        } else {
                            leaderboardEntryRow(entry: entry, rank: Int(entry.rank))
                        }
                    }
                }
            }
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
    
    // MARK: - Leaderboard Entry Row
    private func leaderboardEntryRow(entry: any LeaderboardEntry, rank: Int) -> some View {
        
        return HStack(alignment: .bottom, spacing: 16) {
            
            rankView(entry, rank: rank)
            
            // Avatar
            ProfilePicture(url: entry.profilePictureURL, level: entry.level)
            
            VStack {
                HStack {
                    // Name and Class
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(entry.avatarName?.uppercased() ?? "UNKNOWN")
                                .font(.mainFont(size: 17.5))
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .bold()
                                .foregroundColor(.title)
                            if let path = entry.heroPath {
                                Image(path.iconName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16)
                            }
                        }
                        if let faction = entry.faction {
                            Text(faction.name)
                                .font(.system(size: 12))
                                .foregroundColor(faction.baseColor)
                                .italic()
                        }
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
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                selectedEntry = entry
            }
        }
    }
    
    private func getClassForEntry(_ entry: any LeaderboardEntry) -> String {
        // Map entry data to class names that match the image
        let classes = ["Neurospire", "Pulseforge", "Echoreach", "Voidling"]
        return classes.randomElement() ?? "Neurospire"
    }
    
    private func formatScore(_ score: Int) -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: score), number: .decimal)
    }
    
    func rankView(_ entry: any LeaderboardEntry, rank: Int) -> some View {
        var isUnranked: Bool {
            if let _ = entry as? XpLeaderboardEntry {
                return entry.value == 0
            } else if let _ = entry as? StreakLeaderboardEntry {
                return entry.value == 0
            } else {
                return false
            }
        }
        let rankText = isUnranked ? "-" : getRankDisplay(rank)
        return Text(rankText)
            .font(.system(size: 13))
            .foregroundColor(rankColor)
            .padding(.bottom, 12)
            .frame(width: 32)
    }
    
    func getRankDisplay(_ rank: Int) -> String {
        switch rank {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        default: return "\(rank)th"
        }
    }
    // MARK: - Faction Leaderboard Row
    @ViewBuilder
    private func factionLeaderboardRow(entry: FactionLeaderboardEntry, rank: Int) -> some View {
        
        if let faction = entry.faction {
            HStack(spacing: 30) {
                // Left side - Rank and Total XP
                VStack(alignment: .center, spacing: 4) {
                    Text(getRankDisplay(rank))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.title)
                    Text(formatScore(entry.totalXp))
                        .font(.system(size: 15))
                        .foregroundColor(.title)
                }
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center, spacing: 13) {
                        Image(faction.iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(faction.baseColor)
                            .frame(width: 32, height: 32)
                        Text(faction.name)
                            .font(.system(size: 22))
                            .foregroundColor(faction.baseColor)
                            .italic()
                    }
                    Rectangle().fill(.white.opacity(0.3)).frame(height: 1)
                    HStack(alignment: .center, spacing: 12) {
                        ZStack(alignment: .bottom) {
                            CachedAsyncImage(url: URL(string: entry.topPlayerImage ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image("profile_placeholder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                            .frame(width: 35, height: 35)
                            Text("\(entry.topPlayerLevel)")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.7))
                                .bold()
                                .padding(.horizontal, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(Color.textfieldBorder)
                                        .strokeBorder(Color.majorDark)
                                        .frame(height: 15)
                                        .frame(minWidth: 15)
                                )
                                .offset(y: 4)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Faction Leader")
                                .font(.system(size: 10))
                                .foregroundColor(.textDetail)
                                .textCase(.uppercase)
                            Text(entry.topPlayerName)
                                .font(.mainFont(size: 16))
                                .bold()
                                .foregroundColor(.title)
                        }
                        Spacer()
                        VStack(alignment: .center, spacing: 4) {
                            Image("faction_icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                            Text("\(entry.topPlayerXp)")
                                .font(.system(size: 14))
                                .foregroundColor(.title)
                        }
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.1))
            )
        } else {
            EmptyView()
        }
    }
}

#Preview {
    let _ = Container.shared.setupMocks()
    LeaderboardView()
}
