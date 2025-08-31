//
//  OnboardingView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/13/25.
//

import SwiftUI
import FactoryKit

enum AvatarType: CaseIterable {
    case typeA
    case typeB
    
    var title: String {
        switch self {
        case .typeA: return "Type A"
        case .typeB: return "Type B"
        }
    }
}

struct OnboardingView: View {
    @InjectedObservable(\.appState) var appState
    @Injected(\.avatarService) var avatarService
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var avatarName: String = ""
    @State private var isLoading: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var selectedAvatarType: AvatarType = .typeA
    @State private var selectedAvatarIndex: Int = 0
    @State private var avatarAssets: [AvatarAsset] = []
    @State private var isLoadingAssets: Bool = false
    @StateObject private var imageLoader = DynamicImageLoader()
    
    private let avatarNameMaxLength: Int = 16
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 36) {
                    LoginHeader()
                        .frame(width: proxy.size.width * 0.7)
                    LUDivider()
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.mainFont(size: 32).bold())
                            .foregroundStyle(Color.title)
                            .multilineTextAlignment(.center)
                        Text("Before you start your fitness journey, let's set up your profile.")
                            .font(.body)
                            .foregroundColor(.white)
                    }
                    .multilineTextAlignment(.center)
                    fields
                    
                    LUButton(title: "Create Account", isLoading: isLoading, fillSpace: true) {
                        saveProfile()
                    }
                    .disabled(isLoading || firstName.isEmpty || lastName.isEmpty || avatarName.isEmpty)
                    
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .padding(.horizontal, 40)
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Error"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .scrollIndicators(.hidden)
        }
        .mainBackground()
        .onAppear {
            loadAvatarAssets()
        }
    }
    
    var fields: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                LUTextField(title: "First Name", text: $firstName)
                    .textContentType(.givenName)
                    .autocapitalization(.words)
                
                LUTextField(title: "Last Name", text: $lastName)
                    .textContentType(.familyName)
                    .autocapitalization(.words)
            }
            LUTextField(title: "Avatar Name",
                        detail: "\(avatarName.count)/\(avatarNameMaxLength)",
                        text: $avatarName,
                        maxLength: avatarNameMaxLength)
                .autocapitalization(.words)
            
            avatarSelection
            
        }
    }
    
    func nextAvatar() {
        let nextIndex = selectedAvatarIndex + 1
        if nextIndex > avatarAssets.count - 1 {
            selectedAvatarIndex = 0
        } else {
            selectedAvatarIndex = nextIndex
        }
    }
    
    func previousAvatar() {
        let nextIndex = selectedAvatarIndex - 1
        if nextIndex < 0 {
            selectedAvatarIndex = avatarAssets.count - 1
        } else {
            selectedAvatarIndex = nextIndex
        }
    }
    
    private var selectedAvatarImageUrl: String? {
        guard !isLoadingAssets, selectedAvatarIndex < avatarAssets.count else {
            return nil
        }
        let currentAsset = avatarAssets[selectedAvatarIndex]
        return currentAsset.profileImageUrl(for: selectedAvatarType)
    }
    
    private var avatarSelection: some View {
        VStack(alignment: .center, spacing: 16) {
            // Avatar type selection buttons
            HStack(spacing: 12) {
                ForEach(AvatarType.allCases, id: \.self) { avatarType in
                    Button(action: {
                        selectedAvatarType = avatarType// Reset to first avatar of selected type
                    }) {
                        Text(avatarType.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(selectedAvatarType == avatarType ? .white : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedAvatarType == avatarType ? Color.textfieldBorder : Color.gray.opacity(0.3))
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            
            // Avatar carousel
            HStack {
                // Previous button
                Button(action: {
                    previousAvatar()
                }) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 20, height: 50)
                }
                
                // Avatar display
                VStack {
                    if isLoadingAssets {
                        ProgressView()
                        
                        Text("Loading...")
                            .font(.caption)
                            .foregroundColor(.white)
                    } else {
                        avatarImage(selectedAvatarImageUrl ?? "")
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode : .fill)
                .background(
                    Color.white.opacity(0.2)
                )
                
                // Next button
                Button(action: {
                    nextAvatar()
                }) {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 20, height: 50)
                }
            }
            Text("Select Your Avatar")
                .font(.system(size: 17))
                .foregroundStyle(.textDetail)
        }
        .padding(.top)
    }
    
    private func avatarImage(_ urlString: String) -> some View {
        AsyncImage(url: URL(string: urlString)) { image in
            image
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } placeholder: {
            ProgressView()
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
        }
    }
    
    private func loadAvatarAssets() {
        guard !isLoadingAssets else { return }
        isLoadingAssets = true
        
        Task {
            let result = await avatarService.fetchAvatarAssets()
            await MainActor.run {
                isLoadingAssets = false
                switch result {
                case .success(let assets):
                    avatarAssets = assets
                    preloadProfileImages()
                case .failure(let error):
                    alertMessage = "Failed to load avatar options: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func preloadProfileImages() {
        guard !avatarAssets.isEmpty else { return }
        
        var urlsToPreload: [URL] = []
        
        for asset in avatarAssets {
            if let profileA = URL(string: asset.typeAProfileImageUrl) {
                urlsToPreload.append(profileA)
            }
            if let profileB = URL(string: asset.typeBProfileImageUrl) {
                urlsToPreload.append(profileB)
            }
        }
        
        imageLoader.preloadImages(urls: urlsToPreload)
    }
    
    private func saveProfile() {
        guard !firstName.isEmpty, !lastName.isEmpty, !avatarName.isEmpty else {
            alertMessage = "Please fill in all fields"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            // Get selected avatar URLs
            let selectedAvatar = avatarAssets[selectedAvatarIndex]
            let fullBody = selectedAvatar.fullBodyImageUrl(for: selectedAvatarType)
            let profile = selectedAvatar.profileImageUrl(for: selectedAvatarType)
            
            // Create profile with selected avatar URLs
            let result = await appState.createProfile(
                firstName: firstName,
                lastName: lastName,
                avatarName: avatarName,
                avatarUrl: fullBody,
                profilePictureUrl: profile
            )
            
            await MainActor.run {
                isLoading = false
                
                switch result {
                case .success:
                    // Profile created successfully, AppState will handle the navigation
                    break
                case .failure(let error):
                    alertMessage = "Failed to create profile: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
