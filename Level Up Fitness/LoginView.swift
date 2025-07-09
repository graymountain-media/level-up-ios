import SwiftUI

struct LoginView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ZStack {
            // Background will be added later
            Image("LoginBG")
            VStack(spacing: 20) {
                Spacer()
                
                // Form Fields
                VStack(spacing: 15) {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.givenName)
                        .autocapitalization(.words)
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.familyName)
                        .autocapitalization(.words)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.newPassword)
                }
                .padding(.horizontal, 30)
                
                // Sign Up Button
                Button(action: {
                    // Handle sign up
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Login Link
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.white)
                    
                    Button("Log In") {
                        // Show login
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
                }
                .padding(.bottom, 30)
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
}
