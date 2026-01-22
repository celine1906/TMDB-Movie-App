//
//  TVShowDetail.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 21/01/26.
//

import Foundation

struct TVShowDetail: Codable {
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let firstAirDate: String?
    let voteAverage: Double
    let episodeRunTime: [Int]
    let genres: [TVGenre]
    let tagline: String?

    enum CodingKeys: String, CodingKey {
        case id, name, overview, genres, tagline
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
        case episodeRunTime = "episode_run_time"
    }

    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: APIConstants.imageBaseURL + path)
    }

    var runtimeText: String {
        guard let runtime = episodeRunTime.first else { return "" }
        return "\(runtime)m / episode"
    }

    var genresText: String {
        genres.map { $0.name }.joined(separator: ", ")
    }
}

struct TVGenre: Codable {
    let id: Int
    let name: String
}
