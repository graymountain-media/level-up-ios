import SwiftUI
import FactoryKit

struct MissionBoardView: View {
    @State private var viewModel = MissionBoardViewModel()
    @State var selectedMission: Mission?
    
    var body: some View {
        VStack(spacing: 0) {
            FeatureHeader(title: "Mission Board")
            
            // Content based on selected tab
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.availableMissions.isEmpty {
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
        .mainBackground()
        .task {
            await viewModel.loadAllMissions()
        }
    }
    
    var missionCards: some View {
        VStack(spacing: 20) {
            ForEach(viewModel.availableMissions) { mission in
                if selectedMission == nil || selectedMission?.id == mission.id {
                    MissionCard(mission: mission, isSelected: selectedMission?.id == mission.id) {
                        print("Tapped")
                        if selectedMission != nil {
                            withAnimation {
                                selectedMission = nil
                            }
                        } else {
                            withAnimation {
                                selectedMission = mission
                            }
                        }
                    } onSelect: {
                        viewModel.startMission(mission)
                    }
                    .id(mission.id)
                    .padding(.horizontal)
                    .transition(.opacity)
                }
            }
        }
        .frame(maxWidth: .infinity)
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
    let _ = Container.shared.setupMocks()
    MissionBoardView()
}
