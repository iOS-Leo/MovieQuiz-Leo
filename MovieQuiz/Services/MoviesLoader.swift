

import Foundation
protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    
    private let networkClient: NetworkRouting
    private let decoder = JSONDecoder()
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    private var mostPopularMoviesUrl: URL {
        
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    
                    let mostPopularMovies = try decoder.decode(MostPopularMovies.self, from: data)
                    
                    if !mostPopularMovies.errorMessage.isEmpty {
                        
                        let error = NSError(domain: "IMDb API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: mostPopularMovies.errorMessage])
                        handler(.failure(error))
                    } else {
                        handler(.success(mostPopularMovies))
                    }
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}


