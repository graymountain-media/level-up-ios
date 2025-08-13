import SwiftUI
import FactoryKit

struct MissionBoardView: View {
    @InjectedObservable(\.missionManager) var missionManager
    @InjectedObservable(\.appState) var appState
    @State var selectedMission: Mission?
    @State var isLoading: Bool = false
    @State var startingMission: Mission?
    @State var selectedTab: MissionBoardTab = .available
    @State var tipManager = SequentialTipsManager.missionTips()
    @Namespace var namespace
    var body: some View {
        VStack(spacing: 0) {
            FeatureHeader(title: "Mission Board")
            
            tabSelector
                .padding(.bottom, 10)
            
            if isLoading {
                Spacer()
                ProgressView("Loading missions...")
                    .padding()
                Spacer()
            } else if let error = missionManager.errorMessage {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                        .padding(.horizontal, 40)
                    Button("Retry") {
                        Task { await missionManager.loadAllMissions(appState.userAccountData?.currentLevel ?? 1) }
                    }
                    .buttonStyle(.borderedProminent)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        if missionsForSelectedTab.isEmpty {
                            emptyStateView(message: "No missions available. Check back later for new challenges!")
                        } else {
                            missionCards.transition(.move(edge: .bottom))
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
#if DEBUG
        .task {
            // Load user data if not already loaded
            if appState.userAccountData == nil && appState.isAuthenticated {
                print("Getting userdata")
                await appState.loadUserData()
            }
        }
        #endif
        .tipOverlay(namespace: namespace, manager: tipManager)
        .mainBackground()
        .task {
            isLoading = true
            print("Getting missions for level: \(appState.userAccountData?.currentLevel)")
            await missionManager.loadAllMissions(appState.userAccountData?.currentLevel ?? 17)
            isLoading = false
            
            // Show welcome tip
            if !missionsForSelectedTab.isEmpty {
                tipManager.showSingleTip(key: "welcome")
            }
        }
        .overlay {
            // Mission Result Popup
            if let result = missionManager.missionResult {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        missionManager.dismissMissionResult()
                    }
                
                MissionResultPopupView(result: result) {
                    missionManager.dismissMissionResult()
                }
                .transition(.scale)
            }
        }
    }
    
    var missionCards: some View {
        VStack(spacing: 20) {
            ForEach(missionsForSelectedTab) { mission in
                let card = MissionCard(
                    mission: mission,
                    isSelected: selectedMission?.id == mission.id,
                    isLoading: startingMission == mission,
                    isActiveMission: selectedTab == .active,
                    isCompletedMission: selectedTab == .completed) {
                    
                    if selectedMission == mission {
                        withAnimation {
                            selectedMission = nil
                        }
                    } else {
                        withAnimation {
                            selectedMission = mission
                        }
                        
                        // Show first expansion tip
                        tipManager.showSingleTip(key: "first_expansion")
                        
                    }
                } onSelect: {
                    Task {
                        startingMission = mission
                        await missionManager.startMission(mission)
                        startingMission = nil
                        selectedTab = .active
                    }
                } onComplete: {
                    Task {
                        await missionManager.completeMission(mission, userPath: appState.userAccountData?.profile.path)
                        selectedMission = nil
                        selectedTab = .completed
                    }
                }
                .padding(.horizontal)
                .transition(.opacity)
                if selectedTab == .available {
                    if selectedMission?.id == mission.id {
                        card
                            .tipSource(id: 1, nameSpace: namespace, manager: tipManager, anchorPoint: .top)
                    } else {
                        card
                            .tipSource(id: 0, nameSpace: namespace, manager: tipManager, anchorPoint: .bottom)
                    }
                } else {
                    card
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var missionsForSelectedTab: [Mission] {
        switch selectedTab {
        case .available:
            return missionManager.availableMissions
        case .active:
            return missionManager.activeMissions
        case .completed:
            return missionManager.completedMissions
        }
    }
    
    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    private var tabSelector: some View {
        return HStack(spacing: 4) {
            ForEach(MissionBoardTab.allCases) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    Text(tab.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(height: 36)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(selectedTab == tab ? Color.textInput : Color.textfieldBorder)
                        )
                }
            }
        }
        .padding(.horizontal, 48)
    }
}

#Preview {
    let _ = Container.shared.setupMocks()
    MissionBoardView()
}
