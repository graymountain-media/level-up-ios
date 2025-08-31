import SwiftUI
import FactoryKit

struct AddFriendsSearchView: View {
    @Injected(\.friendsService) var friendsService
    @State private var searchText = ""
    @State private var searchResults: [SearchableUser] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var sentRequests: Set<UUID> = []
    
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            FeatureHeader(title: "Add Friends", showCloseButton: true, onDismiss: onDismiss)
                .padding(.horizontal)
            
            // Search Bar
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textDetail)
                        .font(.system(size: 16))
                    
                    TextField("Search by avatar name...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.textInput)
                        .font(.system(size: 16))
                        .onChange(of: searchText) { _, newValue in
                            Task {
                                await performSearch(query: newValue)
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            searchResults = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.textDetail)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            
            // Search Results
            if isSearching {
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.textOrange)
                    Spacer()
                }
            } else if searchResults.isEmpty && !searchText.isEmpty {
                VStack {
                    Spacer()
                    
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.bottom, 16)
                    
                    Text("No users found")
                        .font(.mainFont(size: 18))
                        .bold()
                        .foregroundColor(.title)
                    
                    Text("Try a different avatar name")
                        .font(.system(size: 14))
                        .foregroundColor(.textDetail)
                    
                    Spacer()
                }
            } else if searchText.isEmpty {
                VStack {
                    Spacer()
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.bottom, 16)
                    
                    Text("Search for Friends")
                        .font(.mainFont(size: 18))
                        .bold()
                        .foregroundColor(.title)
                    
                    Text("Enter an avatar name to find other users")
                        .font(.system(size: 14))
                        .foregroundColor(.textDetail)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(searchResults) { user in
                            SearchResultRowView(
                                user: user,
                                isRequestSent: sentRequests.contains(user.userId),
                                onSendRequest: {
                                    await sendFriendRequest(to: user)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(
            Color.major
                .ignoresSafeArea()
        )
    }
    
    private func performSearch(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        // Add a small delay to debounce the search
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Check if search text is still the same (user might have continued typing)
        guard query == searchText else { return }
        
        isSearching = true
        errorMessage = nil
        
        let result = await friendsService.searchUsers(query: query.trimmingCharacters(in: .whitespacesAndNewlines))
        
        switch result {
        case .success(let users):
            searchResults = users
        case .failure(let error):
            errorMessage = error.localizedDescription
            searchResults = []
        }
        
        isSearching = false
    }
    
    private func sendFriendRequest(to user: SearchableUser) async {
        let result = await friendsService.sendFriendRequest(to: user.userId)
        
        switch result {
        case .success:
            sentRequests.insert(user.userId)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

struct SearchResultRowView: View {
    let user: SearchableUser
    let isRequestSent: Bool
    let onSendRequest: () async -> Void
    
    @State private var isSendingRequest = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack(alignment: .bottom) {
                ProfilePicture(url: user.profilePictureUrl)
                Text("\(user.currentLevel)")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .bold()
                    .offset(y: 7)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Display Name
                Text(user.avatarName.uppercased())
                    .font(.mainFont(size: 15))
                    .bold()
                    .foregroundColor(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                HStack(spacing: 4) {
                    if let faction = user.faction {
                        HStack(spacing: 4) {
                            Text(faction.name)
                                .font(.system(size: 12))
                                .foregroundColor(faction.baseColor)
                                .italic()
                            Image(faction.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        }
                    }
                    if let path = user.path {
                        HStack(spacing: 4) {
                            Text(path.name)
                                .font(.system(size: 12))
                                .foregroundColor(.textOrange)
                                .italic()
                            // Path icon (if available)
                            Image(path.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            VStack(alignment: .trailing, spacing: 4) {
                // Add Friend Button
                if isRequestSent {
                    Text("Request Sent")
                        .font(.system(size: 10))
                        .bold()
                        .foregroundStyle(.white)
                        .frame(height: 24)
                        .padding(.horizontal, 12)
                        .background {
                            Capsule()
                                .fill(.green.opacity(0.3))
                                .overlay(
                                    Capsule()
                                        .stroke(.green, lineWidth: 1)
                                )
                        }
                } else {
                    Button {
                        Task {
                            isSendingRequest = true
                            await onSendRequest()
                            isSendingRequest = false
                        }
                    } label: {
                        if isSendingRequest {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(height: 24)
                                .padding(.horizontal, 12)
                        } else {
                            Text("Add Friend")
                                .font(.system(size: 10))
                                .bold()
                                .foregroundStyle(.black)
                                .frame(height: 24)
                                .padding(.horizontal, 12)
                                .background {
                                    Capsule()
                                        .fill(.textOrange)
                                }
                        }
                    }
                    .disabled(isSendingRequest)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let _ = Container.shared.setupMocks()
    AddFriendsSearchView {
        // Dismiss action
    }
}
