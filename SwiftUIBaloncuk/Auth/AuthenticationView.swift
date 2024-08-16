import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var appState: AppState
    @State private var isSigninUp = false
    @Environment(\.colorScheme) var colorScheme
    
    enum  Selections: String {
        case login = "Sign In"
        case signup = "Sign Up"
    }
    
    var selections: [Selections] = [.login, .signup]
    @State private var selection = Selections.login
    @State private var circleData: [(size: CGFloat, offsetX: CGFloat, offsetY: CGFloat)] = []
    private let circleCount = 12
    
    @State private var isAppeared = false
    
    
    @State var email_login: String = ""
    @State var password_login: String = ""
    @State var username_sign: String = ""
    @State var password_sign: String = ""
    @State var email   : String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                                    colors: colorScheme == .dark ?
                                        [Color.black, Color.white] : // Karanlık modda
                                        [Color.white, Color.black],  // Açık modda
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .ignoresSafeArea()
                
                CircleAnimationView(circleData: $circleData, circleCount: circleCount)
                VStack {
                    Picker("?", selection: $selection) {
                        ForEach(selections, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .frame(height: 58)
                    .pickerStyle(.segmented)
                    .padding()
                    
                    switch selection {
                    case .login:
                        LoginView(email: $email_login, password: $password_login)
                            .environmentObject(appState)
                    case .signup:
                        SignUpView(username: $username_sign, password: $password_sign, email: $email)
                            .environmentObject(appState)
                    }
                    Spacer()
                }
            }
            .navigationTitle(selection ==  .signup ? "Sign Up" : "Sign In")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                setupInitialData()
                startAnimation()
            }
        }
    }
    
    
    // MARK: - Background Animations
    
    private func setupInitialData() {
        for _ in 0..<circleCount {
            let size = CGFloat.random(in: 150...400)
            let offsetX = CGFloat.random(in: -150...300)
            let offsetY = CGFloat.random(in: -500...500)
            circleData.append((size: size, offsetX: offsetX, offsetY: offsetY))
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 7)) {
                updateCircleData()
            }
        }
    }
    
    private func updateCircleData() {
        for index in 0..<circleCount {
            let newSize = CGFloat.random(in: 50...200)
            let newOffsetX = CGFloat.random(in: -150...300)
            let newOffsetY = CGFloat.random(in: -500...500)
            circleData[index] = (size: newSize, offsetX: newOffsetX, offsetY: newOffsetY)
        }
    }
    
    struct CircleAnimationView: View {
        @Binding var circleData: [(size: CGFloat, offsetX: CGFloat, offsetY: CGFloat)]
        @Environment(\.colorScheme) var colorScheme
        let circleCount: Int
        
        var body: some View {
            ZStack {
                ForEach(0..<circleCount, id: \.self) { index in
                    Circle()
                        .blur(radius: 5.0)
                        .frame(width: circleData.indices.contains(index) ? circleData[index].size : 50, height: circleData.indices.contains(index) ? circleData[index].size : 50)
                        .opacity(CGFloat.random(in: 0.1...0.4))
                        .offset(x: circleData.indices.contains(index) ? circleData[index].offsetX : 0, y: circleData.indices.contains(index) ? circleData[index].offsetY : 0)
                        .foregroundColor(colorScheme == .dark ? .black.opacity(0.7) : .white.opacity(0.7))
                }
            }
        }
    }
}
#Preview {
    AuthenticationView()
}
