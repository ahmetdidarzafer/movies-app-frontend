import SwiftUI

struct LoginView: View {
    @Binding var email: String
    @Binding var password: String
    @State private var errorMessage: String = ""
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 30) {
            // Email Input
            HStack {
                Image(systemName: "mail")
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .textContentType(.username)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
            }
            .padding()
            .frame(width: 300, height: 50)
            .background(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            .cornerRadius(10)
            
            // Password Input
            HStack {
                Image(systemName: "lock")
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                SecureField("Password", text: $password)
                    .autocapitalization(.none)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
            }
            .padding()
            .frame(width: 300, height: 50)
            .background(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            .cornerRadius(10)
            
            // Login Button
            Button {
                logIn(password: password, email: email)
            } label: {
                HStack {
                    Text("Sign In")
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                    Image(systemName: "arrow.right")
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                }
                .frame(width: 300, height: 54)
                .background(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                .cornerRadius(10)
            }
            
            // Error Message
            Text(errorMessage)
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .padding()
        }
        .padding()
    }
    
    struct LogInResponse: Codable {
        let message: String
        let user: User
        let token: String
    }
    
    struct User: Codable {
        let username: String
        let email: String
        let id: Int
        let profileImageUrl: String?
    }
    
    func logIn(password: String, email: String) {
        guard let url = URL(string: "http://localhost:3000/user/login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            handleResponse(data: data, response: response, error: error)
        }.resume()
    }
    
    func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.errorMessage = "Error: \(error.localizedDescription)"
            }
            return
        }
        
        guard let data = data else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid data"
            }
            return
        }
        
        do {
            let loginResponse = try JSONDecoder().decode(LogInResponse.self, from: data)
            DispatchQueue.main.async {
                let token = loginResponse.token
                UserDefaults.standard.setValue(token, forKey: "token")
                self.appState.user = loginResponse.user
                self.appState.isLoggedIn = true
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(email: .constant(""), password: .constant(""))
            .environmentObject(AppState())
    }
}
