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

    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Safely handle photoUrl if it's nil
        let photoUrl = authDataResult.user.photoURL?.absoluteString ?? "No Photo URL"
        
        // Return the result model
        return AuthDataResultModel(
            user: authDataResult.user
        )
    }
}
