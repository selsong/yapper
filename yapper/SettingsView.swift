import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Sign-out function
    func signOut() throws {
        try AuthManager.shared.signOut()
    }
    
    // Delete account method
    func deleteAccount(email: String, password: String) async throws {
        // Re-authenticate first
        try await AuthManager.shared.reauthenticateUser(email: email, password: password)
        
        // Proceed with deleting the account
        try await AuthManager.shared.deleteAccount()
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var showEmailPasswordFields = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // State to track error and success messages
    @State private var statusMessage: String? = nil
    @State private var isSuccess: Bool = false
    
    // State to trigger navigation to LoginView
    @State private var navigateToLogin = false
    
    var body: some View {
        VStack {
            List {
                Button("Log out") {
                    Task {
                        do {
                            try viewModel.signOut()
                            navigateToLogin = true
                        } catch {
                            alertMessage = "Error during sign out: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                }
                .padding(.horizontal, 25)
                
                Button("Delete Account") {
                    // Show the email/password fields when clicked
                    withAnimation {
                        showEmailPasswordFields.toggle()
                    }
                }
                .padding(.horizontal, 25)
                
                if showEmailPasswordFields {
                    VStack {
                        // Email and Password Fields
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button(action: {
                            reauthenticateAndDeleteAccount()
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Confirm Delete Account")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                        }
                        .disabled(viewModel.isLoading || email.isEmpty || password.isEmpty)
                        .padding(.horizontal, 25)
                        
                        // Display error or success message
                        if let statusMessage = statusMessage {
                            Text(statusMessage)
                                .font(.subheadline)
                                .foregroundColor(isSuccess ? .green : .red)
                                .padding(.top, 10)
                            
                            // Display instructions to log out and log back in if error occurs
                            if !isSuccess {
                                Text("If the error persists, log out and log back in.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.top, 5)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(isSuccess ? "Success" : "Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onChange(of: navigateToLogin) { _ in
            if navigateToLogin {
                // Navigate to the login screen after account deletion or logout
                NavigationLink("", destination: RootView(), isActive: $navigateToLogin)
            }
        }
    }
    
    private func reauthenticateAndDeleteAccount() {
        Task {
            viewModel.isLoading = true
            viewModel.errorMessage = nil
            
            do {
                try await viewModel.deleteAccount(email: email, password: password)
                viewModel.isLoading = false
                statusMessage = "Account deleted successfully."
                isSuccess = true
                navigateToLogin = true
            } catch {
                viewModel.isLoading = false
                statusMessage = "Failed to delete account: \(error.localizedDescription)"
                isSuccess = false
                showAlert = true
            }
        }
    }
}
