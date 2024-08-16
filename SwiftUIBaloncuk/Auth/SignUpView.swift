import SwiftUI

struct SignUpView: View {
    @Binding var username: String
    @Binding var password: String
    @Binding var email: String
    @State private var errorMessage: String = ""
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Image(systemName: "mail")
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
            }
            .padding()
            .frame(width: 300, height: 50)
            .background(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            .cornerRadius(10)
            
            HStack {
                Image(systemName: "person")
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .textContentType(.username)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
            }
            .padding()
            .frame(width: 300, height: 50)
            .background(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            .cornerRadius(10)
            
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
            
            Button {
                signUp(email: email, password: password, username: username)
            } label: {
                HStack {
                    Text("Sign Up")
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                    Image(systemName: "arrow.right")
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                }
                .frame(width: 300, height: 54)
                .background(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                .cornerRadius(10)
            }
            
        }
        .padding()
    }
    
    struct User: Codable {
        let username: String
        let email: String
        let password: String
        let id: Int
    }
    struct SignUpResponse: Codable {
        let message: String
        let user: User
    }
    
    
    
    func signUp(email: String, password: String, username: String) {
        guard let url = URL(string: "http://localhost:3000/user/signUp") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["username": username, "email": email, "password": password]
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
        
        let json = try? JSONSerialization.jsonObject(with: data)
        
        if let httpResponse = response as? HTTPURLResponse {
            do {
                let signUpResponse = try JSONDecoder().decode(SignUpView.SignUpResponse.self, from: data)
                DispatchQueue.main.async {
                    //self.appState.user = signUpResponse.user // Ad alanını belirtin
                    //self.appState.isLoggedIn = true
                    self.errorMessage = signUpResponse.message
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid response"
            }
        }
    }

}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(username: .constant(""), password: .constant(""), email: .constant(""))
            .environmentObject(AppState())
    }
}
