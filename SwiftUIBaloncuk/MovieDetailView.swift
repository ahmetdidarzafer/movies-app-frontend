import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let posterPath = movie.posterPath {
                let imageUrl = "https://image.tmdb.org/t/p/w500" + posterPath
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            }
            HStack{
                Text(movie.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button{
                    TmdbViewModel().addToFavs(id: movie.id)
                }label: {
                    Image(systemName:"plus")
                }
                .frame(width: 20, height: 20)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            
            if let voteAverage = movie.voteAverage {
                Text(String(format: "Rating: %.1f", voteAverage))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(movie.overview)
                .font(.body)
                .padding(.top, 10)

            Spacer()
        }
        .padding()
        .navigationTitle("Movie Details")
    }
}

//struct MovieDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MovieDetailView(movie: Movie(id: 1, title: "Sample Movie", overview: "Sample overview", posterPath: nil))
//    }
//}
