import SwiftUI
import FirebaseAuth
@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    // Add this variable to notify when user is logged in
    @Published var isLoggedIn = false

    func signIn() async {
        do {
            // Try to sign in first
            let authResult = try await AuthManager.shared.signIn(email: email, password: password)
            print("Signed in with UID: \(authResult.uid)")
            isLoggedIn = true
            showError = false
        } catch {
            // If sign-in fails, try creating a new account
            do {
                let authResult = try await AuthManager.shared.createUser(email: email, password: password)
                print("Account created with UID: \(authResult.uid)")
                isLoggedIn = true
                showError = false
            } catch {
                // Handle any errors (e.g., email already in use)
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

}

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var navigateToContentView = false
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 40) {
                    Text("Yapper")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)

                    Text("Login or Create an Account")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 15) {
                        TextField("Email", text: $viewModel.email)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding(.bottom, 10)
                        
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
                            await viewModel.signIn()
                        }
                    }) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("AccentColor"))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 25)
                    
                    Spacer()
                }
                .padding(.top, 50)
                .onChange(of: viewModel.isLoggedIn) { isLoggedIn in
                    if isLoggedIn {
                        navigateToContentView = true
                    }
                }
                .padding(.bottom, keyboardHeight)
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        keyboardHeight = keyboardFrame.height
                    }
                }
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    keyboardHeight = 0
                }
            }
            // Automatically navigate to ContentView once logged in
            NavigationLink(destination: ContentView(), isActive: $viewModel.isLoggedIn) {
                EmptyView()
            }
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
