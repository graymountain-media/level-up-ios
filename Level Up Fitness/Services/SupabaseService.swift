import Foundation
import Supabase
import Combine

@Observable
class SupabaseService {
    private let client: SupabaseClient
    
    var currentUser: User?
    var isAuthenticated = false
    var isLoadingSession = false
    
    private var authStateChangeTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init() {
        isLoadingSession = true
        client = SupabaseClient(
            supabaseURL: URL(string: "https://uprgcseatwhpptlmmdjr.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVwcmdjc2VhdHdocHB0bG1tZGpyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIwNzM4NzEsImV4cCI6MjA2NzY0OTg3MX0.D7_ahKtqoYAmfuHs4YX50yQhIkHmX1ChAYvfaD-cqfg"
        )
        
        // Setup session monitoring
        setupAuthStateChange()
        
        // Check for existing session
        Task {
            await checkExistingSession()
            isLoadingSession = false
        }
    }
    
    deinit {
        // Cancel the auth state change task
        authStateChangeTask?.cancel()
    }
    
    // MARK: - Private Methods
    
    private func setupAuthStateChange() {
        // Monitor auth state changes using AsyncStream
        authStateChangeTask = Task {
            for await (event, session) in client.auth.authStateChanges {
                if [.initialSession, .signedIn, .signedOut].contains(event) {
                    isAuthenticated = session != nil
                    currentUser = session?.user
                }
            }
        }
    }
    
    private func checkExistingSession() async {
        do {
            let session = try await client.auth.session
            await MainActor.run {
                currentUser = session.user
                isAuthenticated = true
            }
        } catch {
            // No existing session or error occurred
            print("No existing session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, firstName: String, lastName: String, avatarName: String) async -> Result<Void, Error> {
        do {
            // Sign up the user with metadata
            let _ = try await client.auth.signUp(
                email: email,
                password: password,
                redirectTo: URL(string: "level-up-fitness://login-callback")
            )
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func signIn(email: String, password: String) async -> Result<Void, Error> {
        do {
            let _ = try await client.auth.signIn(
                email: email,
                password: password
            )
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func signOut() async -> Result<Void, Error> {
        do {
            try await client.auth.signOut()
            
            await MainActor.run {
                currentUser = nil
                isAuthenticated = false
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
//    
//    func resetPassword(email: String) async throws {
//        DispatchQueue.main.async { [weak self] in
//            self?.isLoading = true
//            self?.errorMessage = nil
//        }
//        
//        do {
//            try await client.auth.resetPasswordForEmail(email)
//            
//            DispatchQueue.main.async { [weak self] in
//                self?.isLoading = false
//            }
//        } catch {
//            DispatchQueue.main.async { [weak self] in
//                self?.isLoading = false
//                self?.errorMessage = error.localizedDescription
//            }
//            throw error
//        }
//    }
}
