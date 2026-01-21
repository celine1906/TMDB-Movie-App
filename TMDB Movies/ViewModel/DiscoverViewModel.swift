//
//  DiscoverViewModel.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 21/01/26.
//

import Combine

final class DiscoverViewModel: ObservableObject {

    @Published private(set) var items: [PosterPresentable] = []
    @Published var isLoading = false
    @Published var error: NetworkError?

    private var page = 1
    private var canLoadMore = true
    private var discoverType: DiscoverType
    private var cancellables = Set<AnyCancellable>()

    init(type: DiscoverType) {
        self.discoverType = type
    }

    func changeType(_ type: DiscoverType) {
        guard discoverType != type else { return }

        discoverType = type
        page = 1
        canLoadMore = true
        items.removeAll()

        load()
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

        let endpoint = getEndpoint()
        let urlString =
            "\(APIConstants.baseURL)\(endpoint)?api_key=\(APIConstants.apiKey)&page=\(page)"

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
}
