//
//  DetailViewModel.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 21/01/26.
//

import Foundation
import Combine

final class DetailViewModel {

    @Published var movieDetail: MovieDetail?
    @Published var tvDetail: TVShowDetail?
    
    var detailDidUpdate: AnyPublisher<Void, Never> {
        Publishers.Merge(
            $movieDetail.map { _ in () },
            $tvDetail.map { _ in () }
        )
        .eraseToAnyPublisher()
    }

    @Published var reviews: [Review] = []
    @Published var trailerURL: URL?
    @Published var isLoading = false
    @Published var error: NetworkError?

    private let id: Int
    private let type: DiscoverType
    private var cancellables = Set<AnyCancellable>()

    init(id: Int, type: DiscoverType) {
        self.id = id
        self.type = type
    }

    func loadData() {
        isLoading = true
        error = nil

        let group = DispatchGroup()

        group.enter()
        loadDetail { group.leave() }

        group.enter()
        loadReviews { group.leave() }

        group.enter()
        loadVideos { group.leave() }

        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
        }
    }
    
    private func loadDetail(completion: @escaping () -> Void) {
        let urlString =
        "\(APIConstants.baseURL)\(baseDetailPath)\(id)?api_key=\(APIConstants.apiKey)"

        switch type {

        case .movie:
            NetworkService.shared.fetch(MovieDetail.self, from: urlString)
                .sink { [weak self] result in
                    completion()
                    if case .failure(let error) = result {
                        self?.error = error
                    }
                } receiveValue: { [weak self] detail in
                    self?.movieDetail = detail
                }
                .store(in: &cancellables)

        case .tv:
            NetworkService.shared.fetch(TVShowDetail.self, from: urlString)
                .sink { [weak self] result in
                    completion()
                    if case .failure(let error) = result {
                        self?.error = error
                    }
                } receiveValue: { [weak self] detail in
                    self?.tvDetail = detail
                }
                .store(in: &cancellables)
        }
    }

    
    private func loadReviews(completion: @escaping () -> Void) {
        let urlString = "\(APIConstants.baseURL)\(baseDetailPath)\(id)\(APIConstants.Endpoints.reviews)?api_key=\(APIConstants.apiKey)"
        
        NetworkService.shared.fetch(ReviewsResponse.self, from: urlString)
            .sink { _ in
                completion()
            } receiveValue: { [weak self] response in
                self?.reviews = response.results
            }
            .store(in: &cancellables)
    }
    
    private func loadVideos(completion: @escaping () -> Void) {
        let urlString = "\(APIConstants.baseURL)\(baseDetailPath)\(id)\(APIConstants.Endpoints.videos)?api_key=\(APIConstants.apiKey)"
        
        NetworkService.shared.fetch(VideosResponse.self, from: urlString)
            .sink { _ in
                completion()
            } receiveValue: { [weak self] response in
                let trailer = response.results.first { $0.type == "Trailer" && $0.site == "YouTube" }
                self?.trailerURL = trailer?.youtubeURL
            }
            .store(in: &cancellables)
    }
}

private extension DetailViewModel {

    var baseDetailPath: String {
        switch type {
        case .movie:
            return APIConstants.Endpoints.movieDetails
        case .tv:
            return APIConstants.Endpoints.TVDetails
        }
    }
}

extension DetailViewModel {
    var displayTitle: String? {
        switch type {
        case .movie:
            guard let detail = movieDetail else { return nil }
            return "\(detail.title)\(yearText(from: detail.releaseDate))"

        case .tv:
            guard let detail = tvDetail else { return nil }
            return "\(detail.name)\(yearText(from: detail.firstAirDate))"
        }
    }

    private func yearText(from date: String?) -> String {
        guard let date, date.count >= 4 else { return "" }
        return " (\(date.prefix(4)))"
    }
    
    var overviewText: String? {
        switch type {
        case .movie:
            return movieDetail?.overview
        case .tv:
            return tvDetail?.overview
        }
    }

    var taglineText: String? {
        switch type {
        case .movie:
            return movieDetail?.tagline
        case .tv:
            return tvDetail?.tagline
        }
    }

    var infoText: String {
        var text = "\(ratingText)"

        if let runtime = runtimeText, !runtime.isEmpty {
            text += " • \(runtime)"
        }

        return text
    }

    var ratingText: String {
        let value: Double?
        switch type {
        case .movie:
            value = movieDetail?.voteAverage
        case .tv:
            value = tvDetail?.voteAverage
        }
        return String(format: "%.1f", value ?? 0)
    }

    var runtimeText: String? {
        switch type {
        case .movie:
            return movieDetail?.runtimeText
        case .tv:
            return tvDetail?.runtimeText
        }
    }

    var genresText: String? {
        switch type {
        case .movie:
            return movieDetail?.genresText
        case .tv:
            return tvDetail?.genresText
        }
    }

    var backdropURL: URL? {
        switch type {
        case .movie:
            return movieDetail?.backdropURL
        case .tv:
            return tvDetail?.backdropURL
        }
    }
}
