//
//  DiscoverViewModel.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 21/01/26.
//

import Combine
import Foundation

final class DiscoverViewModel: ObservableObject {

    @Published private(set) var items: [PosterPresentable] = []
    @Published private(set) var genres: [GenreItem] = []
    @Published var isLoading = false
    @Published var error: NetworkError?
    @Published var selectedGenre: GenreItem?

    private var page = 1
    private var canLoadMore = true
    private var mode: DiscoverMode = .discover
    private var discoverType: DiscoverType
    private var cancellables = Set<AnyCancellable>()

    init(type: DiscoverType) {
        self.discoverType = type
        loadGenres()
    }

    func changeType(_ type: DiscoverType) {
        guard discoverType != type else { return }

        discoverType = type
        page = 1
        canLoadMore = true
        items.removeAll()
        selectedGenre = nil
        mode = .discover

        loadGenres()
        load()
    }
    
    func loadGenres() {
        let endpoint = discoverType == .movie ?
            APIConstants.Endpoints.movieGenres :
            APIConstants.Endpoints.tvGenres
        
        let urlString = "\(APIConstants.baseURL)\(endpoint)?api_key=\(APIConstants.apiKey)"
        
        NetworkService.shared
            .fetch(GenreResponse.self, from: urlString)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.genres = self?.discoverType == .movie ?
                            GenreConstants.movieGenres :
                            GenreConstants.tvGenres
                    }
                },
                receiveValue: { [weak self] response in
                    self?.genres = response.genres
                }
            )
            .store(in: &cancellables)
    }

    func load(refresh: Bool = false) {
        guard !isLoading, canLoadMore else { return }

        isLoading = true
        error = nil

        if refresh {
            page = 1
            items.removeAll()
            canLoadMore = true
        }

        let urlString = buildURL()

        switch discoverType {

        case .movie:
            NetworkService.shared
                .fetch(MoviesResponse.self, from: urlString)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.isLoading = false
                        if case .failure(let err) = completion {
                            self?.error = err
                        }
                    },
                    receiveValue: { [weak self] response in
                        guard let self else { return }
                        self.items.append(
                            contentsOf: response.results.map { movie in
                                movie as any PosterPresentable
                            }
                        )

                        self.page += 1
                        self.canLoadMore = self.page <= response.totalPages
                    }
                )
                .store(in: &cancellables)

        case .tv:
            NetworkService.shared
                .fetch(TVShowResponse.self, from: urlString)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.isLoading = false
                        if case .failure(let err) = completion {
                            self?.error = err
                        }
                    },
                    receiveValue: { [weak self] response in
                        guard let self else { return }
                        self.items.append(
                            contentsOf: response.results.map { $0 as PosterPresentable }
                        )
                        self.page += 1
                        self.canLoadMore = self.page <= response.totalPages
                    }
                )
                .store(in: &cancellables)
        }
    }

    private func getEndpoint() -> String {
        switch discoverType {
        case .movie:
            return APIConstants.Endpoints.discoverMovies
        case .tv:
            return APIConstants.Endpoints.discoverTV
        }
    }
    
    func search(query: String) {
        guard !query.isEmpty else {
            mode = .discover
            selectedGenre = nil
            load(refresh: true)
            return
        }

        mode = .search(query: query)
        selectedGenre = nil
        page = 1
        items.removeAll()
        canLoadMore = true
        load()
    }
    
    func applyFilter(genre: GenreItem?) {
        selectedGenre = genre
        
        if let genre = genre {
            mode = .filter(genre: genre.id)
        } else {
            mode = .discover
        }
        
        page = 1
        items.removeAll()
        canLoadMore = true
        load()
    }

    private func buildURL() -> String {
        switch mode {

        case .discover:
            return "\(APIConstants.baseURL)\(getEndpoint())?api_key=\(APIConstants.apiKey)&page=\(page)"

        case .search(let query):
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            return "\(APIConstants.baseURL)/search/\(discoverType == .movie ? "movie" : "tv")?api_key=\(APIConstants.apiKey)&query=\(encodedQuery)&page=\(page)"

        case .filter(let genreId):
            return "\(APIConstants.baseURL)\(getEndpoint())?api_key=\(APIConstants.apiKey)&with_genres=\(genreId)&page=\(page)"
        }
    }
}

enum DiscoverType: Int {
    case movie
    case tv
}

enum DiscoverMode {
    case discover
    case search(query: String)
    case filter(genre: Int)
}
