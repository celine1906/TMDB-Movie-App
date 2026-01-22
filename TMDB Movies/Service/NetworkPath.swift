//
//  NetworkPath.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 21/01/26.
//

import Foundation

struct APIConstants {
    static let apiKey = "143593dc0e6b84068c593fb5fedbfe4f"
    static let baseURL = "https://api.themoviedb.org/3"
    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    
    struct Endpoints {
        static let discoverMovies = "/discover/movie"
        static let discoverTV = "/discover/tv"
        static let movieDetails = "/movie/"
        static let TVDetails = "/tv/"
        static let reviews = "/reviews"
        static let videos = "/videos"
        static let movieGenres = "/genre/movie/list"
        static let tvGenres = "/genre/tv/list"
    }
}
