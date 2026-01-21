//
//  MovieDetail.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 21/01/26.
//

import Foundation

struct MovieDetail: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let voteAverage: Double
    let runtime: Int?
    let genres: [Genre]
    let tagline: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres, tagline
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
    
    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: APIConstants.imageBaseURL + path)
    }
    
    var genresText: String {
        genres.map { $0.name }.joined(separator: ", ")
    }
    
    var runtimeText: String {
        guard let runtime = runtime else { return "" }
        let hours = runtime / 60
        let minutes = runtime % 60
        return "\(hours)h \(minutes)m"
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}
