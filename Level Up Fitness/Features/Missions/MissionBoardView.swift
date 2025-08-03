import SwiftUI
import FactoryKit

struct MissionBoardView: View {
    @InjectedObservable(\.missionManager) var missionManager
    @InjectedObservable(\.appState) var appState
    @State var selectedMission: Mission?
    @State var isLoading: Bool = false
    @State var startingMission: Mission?
    @State var selectedTab: MissionBoardTab = .available
    
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
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .mainBackground()
        .task {
            isLoading = true
            await missionManager.loadAllMissions(appState.userAccountData?.currentLevel ?? 1)
            isLoading = false
        }
        .overlay {
            // Mission Result Popup
            if let result = missionManager.missionResult {
                Color.black.opacity(0.4)
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
                MissionCard(
                    mission: mission,
                    isSelected: selectedMission?.id == mission.id,
                    isLoading: startingMission == mission,
                    isActiveMission: selectedTab == .active,
                    isCompletedMission: selectedTab == .completed) {
                    print("Tapped")
                    if selectedMission == mission {
                        withAnimation {
                            selectedMission = nil
                        }
                    } else {
                        withAnimation {
                            selectedMission = mission
                        }
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
                        await missionManager.completeMission(mission)
                        selectedMission = nil
                        selectedTab = .completed
                    }
                }
                .id(mission.id)
                .padding(.horizontal)
                .transition(.opacity)
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
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .frame(height: 27)
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
