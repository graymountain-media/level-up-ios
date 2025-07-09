import SwiftUI

struct MissionBoardView: View {
    @StateObject private var viewModel = MissionBoardViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Spacer()
                Text("Mission Board")
                    .font(.system(size: 18))
                    .bold()
                Button {
                    
                } label: {
                    Text("Active Missions")
                        .bold()
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.accentColor))
                }
                .buttonStyle(.plain)

            }
            .foregroundStyle(Color.white)
            .frame(minHeight: 60)
            .background(
                Rectangle()
                    .fill(Color.missionBoardHeader)
                    .frame(height: 50)
            )
            
            // Content based on selected tab
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.selectedTab == .missionBoard {
                        if viewModel.availableMissions.isEmpty {
                            emptyStateView(message: "No missions available. Check back later for new challenges!")
                        } else {
                            ForEach(viewModel.availableMissions) { mission in
                                MissionCard(mission: mission) {
                                    viewModel.startMission(mission)
                                }
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        if viewModel.activeMissions.isEmpty {
                            emptyStateView(message: "No active missions. Select missions from the Mission Board to get started!")
                        } else {
                            ForEach(viewModel.activeMissions) { mission in
                                MissionCard(mission: mission) {
                                    if mission.status == .inProgress {
                                        viewModel.completeMission(mission)
                                    } else if mission.status == .completed {
                                        viewModel.claimReward(for: mission)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 20)
                }
                .padding(.vertical, 8)
            }
        }
        .background {
            ZStack {
                Color.black.ignoresSafeArea()
                Image("MissionsBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            }
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
}

#Preview {
    NavigationView {
        MissionBoardView()
    }
    .preferredColorScheme(.dark)
}
