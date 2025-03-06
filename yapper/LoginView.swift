import SwiftUI

struct LoginView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: FlashcardGameViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLogin: Bool = true
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Text("Yapper")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                
                Image(systemName: "message.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color("AccentColor"))
                    .padding(.bottom, 20)
                
                Text(isLogin ? "Login to Your Account" : "Create an Account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedTextFieldStyle())
                }
                .padding(.horizontal, 25)
                
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .transition(.opacity)
                }
                
                Button(action: {
                    if isLogin {
                        viewModel.login(email: email, password: password) { success, error in
                            if success {
                                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                UserDefaults.standard.set(email.components(separatedBy: "@").first ?? "User", forKey: "username")
                                isPresented = false
                            } else {
                                errorMessage = error ?? "Login failed"
                                showError = true
                            }
                        }
                    } else {
                        viewModel.signUp(email: email, password: password) { success, error in
                            if success {
                                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                UserDefaults.standard.set(email.components(separatedBy: "@").first ?? "User", forKey: "username")
                                isPresented = false
                            } else {
                                errorMessage = error ?? "Sign up failed"
                                showError = true
                            }
                        }
                    }
                }) {
                    Text(isLogin ? "Login" : "Sign Up")
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
                        showError = false
                    }
                }) {
                    Text(isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login")
                        .foregroundColor(Color("AccentColor"))
                        .font(.subheadline)
                }
                
                if isLogin {
                    Button(action: {
                        // Demo mode - skip login
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set("Demo User", forKey: "username")
                        viewModel.isLoggedIn = true
                        viewModel.username = "Demo User"
                        isPresented = false
                    }) {
                        Text("Continue as Guest")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    .padding(.top, 5)
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
