import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false

    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "No email or password found."
            self.showError = true
            return
        }
        
        do {
            let returnedUserData = try await AuthManager.shared.createUser(email: email, password: password)
            print("Success")
            print(returnedUserData)
            // Handle success logic here, e.g., navigate to a new view
        } catch {
            self.errorMessage = "Error: \(error)"
            self.showError = true
        }
    }
}

struct LoginView: View {
    @State private var isLogin: Bool = true
    @State private var isPresented: Bool = false
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 55) {
                Text("Yapper")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                
                Text(isLogin ? "Login" : "Create an Account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Main Login Part
                VStack(spacing: 15) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedTextFieldStyle())
                }
                .padding(.horizontal, 25)
                
                if viewModel.showError {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .transition(.opacity)
                }
                
                Button(action: {
                    Task {
                        await viewModel.signIn() // Call the async sign-in function
                    }
                }) {
                    Text(isLogin ? "Login" : "Create an Account")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("AccentColor"))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 25)
                .padding(.top, 10)
                
                Button(action: {
                    withAnimation {
                        isLogin.toggle()
                        viewModel.showError = false
                    }
                }) {
                    Text(isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login")
                        .foregroundColor(Color("AccentColor"))
                        .font(.subheadline)
                }
                
                Spacer()
            }
            .padding(.top, 50)
        }
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .foregroundColor(.white)
    }
}
