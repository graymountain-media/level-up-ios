//
//  OnboardingView.swift
//  Level Up Fitness
//
//  Created by Jake Gray on 7/13/25.
//

import SwiftUI
import FactoryKit
import PhotosUI

struct OnboardingView: View {
    @InjectedObservable(\.appState) var appState
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var avatarName: String = ""
    @State private var isLoading: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    
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
    }
    
    var fields: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                LUTextField(title: "First Name", text: $firstName, placeholder: "John")
                    .textContentType(.givenName)
                    .autocapitalization(.words)
                
                LUTextField(title: "Last Name", text: $lastName, placeholder: "Doe")
                    .textContentType(.familyName)
                    .autocapitalization(.words)
            }
            LUTextField(title: "Avatar Name",
                        detail: "\(avatarName.count)/\(avatarNameMaxLength)",
                        text: $avatarName,
                        placeholder: "William Vengence",
                        maxLength: avatarNameMaxLength)
                .autocapitalization(.words)
            
//            VStack {
//                HStack {
//                    Text("Avatar Photo")
//                        .font(.system(size: 20, weight: .regular))
//                        .foregroundStyle(Color.textDetail)
//                    Spacer()
//                }
//                PhotosPicker(
//                    selection: $selectedPhotoItem,
//                    matching: .images, // Filter for PNG images
//                    photoLibrary: .shared()
//                ) {
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.textfieldBg)
//                            .aspectRatio(1, contentMode: .fit)
//                            .overlay {
//                                RoundedRectangle(cornerRadius: 8)
//                                    .stroke(Color.textfieldBorder)
//                            }
//                        
//                        if let avatarImage {
//                            avatarImage
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .clipShape(RoundedRectangle(cornerRadius: 8))
//                        } else {
//                            VStack(spacing: 8) {
//                                Image(systemName: "square.and.arrow.up")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 40, height: 40)
//                                Text("400 x 1500 px (PNG only)\n(optional)")
//                                    .multilineTextAlignment(.center)
//                            }
//                            .foregroundStyle(.minor)
//                        }
//                    }
//                }
//                .onChange(of: selectedPhotoItem) { _, newItem in
//                    Task {
//                        // Reset image first
//                        self.avatarImage = nil
//                        
//                        // Load and validate the new item
//                        guard let data = try? await newItem?.loadTransferable(type: Data.self),
//                              let uiImage = UIImage(data: data) else {
//                            return
//                        }
//                        
//                        // Check dimensions
//                        if uiImage.size.width == 400 && uiImage.size.height == 1500 {
//                            self.avatarImage = Image(uiImage: uiImage)
//                        } else {
//                            // Trigger alert for wrong dimensions
//                            self.alertMessage = "Image must be a 400x1500 PNG."
//                            self.showingAlert = true
//                            self.selectedPhotoItem = nil // Reset selection
//                        }
//                    }
//                }
//            }
            
        }
    }
    
    private func saveProfile() {
        guard !firstName.isEmpty, !lastName.isEmpty, !avatarName.isEmpty else {
            alertMessage = "Please fill in all fields"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            let result = await appState.createProfile(
                firstName: firstName,
                lastName: lastName,
                avatarName: avatarName
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
