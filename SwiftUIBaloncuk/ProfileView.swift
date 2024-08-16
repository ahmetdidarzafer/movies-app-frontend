import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    

    var body: some View {
        VStack {
            if let profileImageUrl = appState.user?.profileImageUrl {
                AsyncImage(url: URL(string: profileImageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.gray)
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gray)
            }

            Text(appState.user?.username ?? "Username")
                .font(.title)
                .padding(.top, 10)

            Text("Email: \(appState.user?.email ?? "N/A")")
                .font(.subheadline)
                .padding(.top, 5)

            Spacer()
            Button(action: {
                // Implement logout functionality here
                appState.isLoggedIn = false
            }) {
                Text("Logout")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
            }
            .padding(.top, 20)

            
        }
        .padding()
        .navigationTitle("Profile")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AppState()) // Mock environment object
    }
}
//            VStack{
//                List(user.fa) { movie in
//                    NavigationLink(destination: MovieDetailView(movie: movie)) {
//                        HStack {
//                            if let posterPath = movie.posterPath {
//                                let imageUrl = "https://image.tmdb.org/t/p/w500" + posterPath
//                                AsyncImage(url: URL(string: imageUrl)) { image in
//                                    image
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 100)
//                                } placeholder: {
//                                    ProgressView()
//                                }
//                            }
//                            VStack(alignment: .leading) {
//                                Text(movie.title)
//                                    .font(.headline)
//                                Text(movie.overview)
//                                    .font(.subheadline)
//                                    .lineLimit(3)
//                                if let voteAverage = movie.voteAverage {
//                                    Text(String(format: "Rating: %.1f", voteAverage))
//                                        .font(.caption)
//                                        .foregroundColor(.secondary)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
