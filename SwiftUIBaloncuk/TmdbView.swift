import SwiftUI
import Foundation

// MARK: - Movie Model
struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    let voteCount: Int?
    let popularity: Double?

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity
    }
}


// MARK: - TmdbViewModel
class TmdbViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func fetchTopRatedMovies() {
        guard let url = URL(string: "http://localhost:3000/movies/topRated") else {
            self.errorMessage = "Invalid URL"
            return
        }

        isLoading = true
        errorMessage = nil

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Authorization Header
        if let token = UserDefaults.standard.string(forKey: "token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            self.errorMessage = "Authorization token not found"
            self.isLoading = false
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "No data returned"
                    return
                }

                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    //print("JSON Response: \(jsonResponse)")
                } catch {
                    //print("Error decoding JSON response: \(error.localizedDescription)")
                }

                do {
                    let movieResponse = try JSONDecoder().decode([Movie].self, from: data)
                    self?.movies = movieResponse
                } catch {
                    self?.errorMessage = "Failed to decode movies: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    func addToFavs(id: Int) {
            guard let url = URL(string: "http://localhost:3000/movies/favorites") else {
                self.errorMessage = "Invalid URL"
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            // Authorization Header
            if let token = UserDefaults.standard.string(forKey: "token") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                self.errorMessage = "Authorization token not found"
                return
            }

            // Request Body
            let body = ["movieId": id]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

            URLSession.shared.dataTask(with: request) { [weak self] _, _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = "Error: \(error.localizedDescription)"
                        return
                    }
                    // Handle success
                    print("Movie \(id) added to favorites")
                }
            }.resume()
        }
}

// MARK: - TmdbView
import SwiftUI
import Foundation

import SwiftUI

struct TmdbView: View {
    @StateObject private var viewModel = TmdbViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading movies...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    List(viewModel.movies) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            HStack {
                                if let posterPath = movie.posterPath {
                                    let imageUrl = "https://image.tmdb.org/t/p/w500" + posterPath
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                                VStack(alignment: .leading) {
                                    Text(movie.title)
                                        .font(.headline)
                                    Text(movie.overview)
                                        .font(.subheadline)
                                        .lineLimit(3)
                                    if let voteAverage = movie.voteAverage {
                                        Text(String(format: "Rating: %.1f", voteAverage))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarItems(
                leading: Text("Welcome back, \(appState.user?.username ?? "Username")")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black),
                trailing: NavigationLink(destination: ProfileView()
                    .environmentObject(appState)) {
                    if let profileImageUrl = appState.user?.profileImageUrl {
                        AsyncImage(url: URL(string: profileImageUrl)) { image in
                            image
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    } else {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            )
            .onAppear {
                viewModel.fetchTopRatedMovies()
            }
        }
    }
}




// MARK: - Preview
struct TmdbView_Previews: PreviewProvider {
    static var previews: some View {
        TmdbView()
    }
}

