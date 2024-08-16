import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var showProfileView: Bool = false
    @Published var user: LoginView.User? = nil
    @Published var userProfileImageUrl: String?
}

struct User: Codable {
    let username: String
    let email: String
    let password: String
    let id: Int
    let profileImageUrl: String?
}
