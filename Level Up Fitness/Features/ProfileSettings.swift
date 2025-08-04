//
//  ProfileSettings.swift
//  Level Up
//
//  Created by Jake Gray on 7/31/25.
//

import SwiftUI
import FactoryKit
import PhotosUI
import CropImage

struct ProfileSettings: View {
    @InjectedObservable(\.appState) var appState
    @Injected(\.avatarService) var avatarService
    @Environment(\.dismiss) var dismiss
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var avatarName: String = ""
    @State private var avatarImage: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var newAvatarImage: Image?
    @State private var avatarImageData: Data?
    @State private var isLoading: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // Profile picture states
    @State private var selectedProfilePhotoItem: PhotosPickerItem?
    @State private var showingImageCropper: Bool = false
    @State private var imageForCropping: UIImage?
    @State private var croppedProfileImage: UIImage?
    @State private var profileImageData: Data?
    @State private var didSave = false
    
    var firstNameText: String {
        return appState.userAccountData?.profile.firstName ?? ""
    }
    
    var lastNameText: String {
        return appState.userAccountData?.profile.lastName ?? ""
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                FeatureHeader(title: "Account Details", showCloseButton: true)
                HStack(alignment: .center, spacing: 16) {
                    profileImage
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(firstNameText) \(lastNameText)")
                            .font(.system(size: 17))
                            .foregroundColor(.textDetail)
                        HStack(alignment: .bottom) {
                            Text("Member")
                                .font(.system(size: 14))
                                .italic()
                                .foregroundColor(.textOrange)
                            Spacer()
                            Button(action: {
                                // Reset password action
                            }) {
                                Text("Reset Password")
                                    .font(.system(size: 14))
                                    .foregroundColor(.textDetail)
                            }
                        }
                    }
                    Spacer(minLength: 4)
                }
                VStack(alignment: .leading, spacing: 18) {
                    LUTextField(title: "First Name", text: $firstName, rightIconName: "pencil")
                    LUTextField(title: "Last Name", text: $lastName, rightIconName: "pencil")
                    LUTextField(title: "Email Address", text: $email, rightIconName: "pencil")
                        .keyboardType(.emailAddress)
                    LUTextField(title: "Avatar Name", text: $avatarName, rightIconName: "pencil")
                }
                avatarImageView
                VStack(spacing: 8) {
                    LUButton(title: "Save Changes", isLoading: isLoading) {
                        saveProfile()
                    }
                    .disabled(isLoading)
                    if didSave {
                        Text("Account Updated")
                            .font(.system(size: 13))
                            .foregroundStyle(.green)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .task {
            firstName = appState.userAccountData?.profile.firstName ?? ""
            lastName = appState.userAccountData?.profile.lastName ?? ""
            email = client.auth.currentUser?.email ?? ""
            avatarName = appState.userAccountData?.profile.avatarName ?? ""
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                // Reset image first
                self.newAvatarImage = nil
                
                // Load and validate the new item
                guard let data = try? await newItem?.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: data) else {
                    return
                }
                
                // Check dimensions
                if uiImage.size.width == 800 && uiImage.size.height == 1000 {
                    self.newAvatarImage = Image(uiImage: uiImage)
                    self.avatarImageData = data // Store the data for upload
                } else {
                    // Trigger alert for wrong dimensions
                    self.alertMessage = "Image must be a 800x1000 PNG."
                    self.showingAlert = true
                    self.selectedPhotoItem = nil // Reset selection
                }
            }
        }
        .onChange(of: selectedProfilePhotoItem) { _, newItem in
            Task {
                print("🖼️ Profile photo selected, loading...")
                
                // Load the selected image for cropping
                guard let data = try? await newItem?.loadTransferable(type: Data.self) else {
                    print("❌ Failed to load image data")
                    await MainActor.run {
                        self.alertMessage = "Failed to load selected image"
                        self.showingAlert = true
                        self.selectedProfilePhotoItem = nil
                    }
                    return
                }
                
                print("📦 Image data loaded: \(data.count) bytes")
                
                guard let uiImage = UIImage(data: data) else {
                    print("❌ Failed to create UIImage from data")
                    await MainActor.run {
                        self.alertMessage = "Invalid image format"
                        self.showingAlert = true
                        self.selectedProfilePhotoItem = nil
                    }
                    return
                }
                
                print("✅ UIImage created: \(uiImage.size)")
                
                await MainActor.run {
                    self.imageForCropping = uiImage
                    self.showingImageCropper = true
                    print("🎭 Showing image cropper")
                }
            }
        }
        .fullScreenCover(isPresented: $showingImageCropper) {
            if let imageForCropping {
                CropImageView(image: imageForCropping, targetSize: .init(width: 300, height: 300), fulfillTargetFrame: true) { result in
                    switch result {
                    case .success(let image):
                        self.croppedProfileImage = image
                    case .failure(let failure):
                        self.showingImageCropper = false
                        self.selectedProfilePhotoItem = nil
                    }
                }
                //                CropImageView(
                //                    image: imageForCropping,
                //                    cropShapeType: .square,
                //                    presetFixedRatios: [.square],
                //                    showAttemptsToReturn: false
                //                ) { croppedImage in
                //                    // Handle successful crop
                //                    self.croppedProfileImage = croppedImage
                //                    self.profileImageData = croppedImage.jpegData(compressionQuality: 0.9)
                //                    self.showingImageCropper = false
                //                } onCancel: {
                //                    // Handle cancellation
                //                    self.showingImageCropper = false
                //                    self.selectedProfilePhotoItem = nil
                //                }
            } else {
                // Fallback if image loading failed
                VStack {
                    Text("Failed to load image")
                        .foregroundColor(.white)
                    Button("Close") {
                        self.showingImageCropper = false
                        self.selectedProfilePhotoItem = nil
                    }
                    .foregroundColor(.orange)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .mainBackground()
    }
    
    var profileImage: some View {
        AsyncImage(url: URL(string: appState.userAccountData?.profile.profilePictureUrl ?? "")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Image("profile_placeholder")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.textfieldBorder, lineWidth: 1)
        }
//        PhotosPicker(
//            selection: $selectedProfilePhotoItem,
//            matching: .images,
//            photoLibrary: .shared()
//        ) {
//            Group {
//                if let croppedProfileImage {
//                    Image(uiImage: croppedProfileImage)
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                } else {
//                    AsyncImage(url: URL(string: appState.userAccountData?.profile.profilePictureUrl ?? "")) { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                    } placeholder: {
//                        Image("profile_placeholder")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                    }
//                }
//            }
//            .frame(width: 64, height: 64)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .overlay {
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color.textfieldBorder, lineWidth: 1)
//            }
//        }
    }
    
    var avatarImageView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Avatar Photo")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(Color.textDetail)
                Spacer()
            }
            
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.textfieldBg)
                        .aspectRatio(0.8, contentMode: .fit) // 800x1000 aspect ratio
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.textfieldBorder)
                        }
                    
                    if let newAvatarImage {
                        newAvatarImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else if let currentAvatarUrl = appState.userAccountData?.profile.avatarUrl, !currentAvatarUrl.isEmpty {
                        AsyncImage(url: URL(string: currentAvatarUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } placeholder: {
                            VStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                Text("800 x 1000 px (PNG only)")
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundStyle(.minor)
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                            Text("800 x 1000 px (PNG only)")
                                .multilineTextAlignment(.center)
                        }
                        .foregroundStyle(.minor)
                    }
                }
            }
        }
    }
    
    private func saveProfile() {
        didSave = false
        guard !firstName.isEmpty, !lastName.isEmpty, !avatarName.isEmpty else {
            alertMessage = "Please fill in all fields"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            var avatarUrl: String? = nil
            
            // Upload new avatar if image is selected
            if let imageData = avatarImageData {
                let fileName = "\(UUID().uuidString).png"
                let currentAvatarUrl = appState.userAccountData?.profile.avatarUrl
                let uploadResult = await avatarService.uploadAvatar(imageData: imageData, fileName: fileName, currentAvatarUrl: currentAvatarUrl)
                
                switch uploadResult {
                case .success(let url):
                    avatarUrl = url
                case .failure(let error):
                    await MainActor.run {
                        isLoading = false
                        alertMessage = "Failed to upload avatar: \(error.localizedDescription)"
                        showingAlert = true
                    }
                    return
                }
            }
            
            // Upload profile picture if image is selected
            var profilePictureUrl: String? = nil
            if let profileData = profileImageData {
                let fileName = "\(UUID().uuidString).jpg"
                let currentProfilePictureUrl = appState.userAccountData?.profile.profilePictureUrl
                let uploadResult = await avatarService.uploadProfilePicture(imageData: profileData, fileName: fileName, currentProfilePictureUrl: currentProfilePictureUrl)
                
                switch uploadResult {
                case .success(let url):
                    profilePictureUrl = url
                case .failure(let error):
                    await MainActor.run {
                        isLoading = false
                        alertMessage = "Failed to upload profile picture: \(error.localizedDescription)"
                        showingAlert = true
                    }
                    return
                }
            }
            
            // Update profile with new URLs if provided
            let result = await appState.updateProfile(
                firstName: firstName,
                lastName: lastName,
                avatarName: avatarName,
                avatarUrl: avatarUrl,
                profilePictureUrl: profilePictureUrl
            )
            
            await MainActor.run {
                isLoading = false
                
                switch result {
                case .success:
                    didSave = true
                case .failure(let error):
                    alertMessage = "Failed to update profile: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}


#Preview {
    let _ = Container.shared.setupMocks()
    ProfileSettings()
}
