import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}

final class AuthManager {
    static let shared = AuthManager()
    private init() {}
    
    // Get the current authenticated user
    func getAuthUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    // Async function to sign in an existing user
    func signIn(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }

    // Async function to create a new user
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // Sign out the current user
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // Async function to reauthenticate the user
    func reauthenticateUser(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }

        // Create the credential for reauthentication
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        // Reauthenticate with Firebase using the created credential
        try await user.reauthenticate(with: credential)
        print("Reauthentication successful.")
    }
    
    // Async function to delete the user's account
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }

        // Delete the account
        try await user.delete()
        print("User account deleted successfully.")
    }
}
