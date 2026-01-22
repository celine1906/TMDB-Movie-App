//
//  Genre.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 22/01/26.
//

import Foundation

struct GenreResponse: Codable {
    let genres: [GenreItem]
}

struct GenreItem: Codable {
    let id: Int
    let name: String
}

struct GenreConstants {
    static let movieGenres: [GenreItem] = [
        GenreItem(id: 28, name: "Action"),
        GenreItem(id: 12, name: "Adventure"),
        GenreItem(id: 16, name: "Animation"),
        GenreItem(id: 35, name: "Comedy"),
        GenreItem(id: 80, name: "Crime"),
        GenreItem(id: 99, name: "Documentary"),
        GenreItem(id: 18, name: "Drama"),
        GenreItem(id: 10751, name: "Family"),
        GenreItem(id: 14, name: "Fantasy"),
        GenreItem(id: 36, name: "History"),
        GenreItem(id: 27, name: "Horror"),
        GenreItem(id: 10402, name: "Music"),
        GenreItem(id: 9648, name: "Mystery"),
        GenreItem(id: 10749, name: "Romance"),
        GenreItem(id: 878, name: "Science Fiction"),
        GenreItem(id: 10770, name: "TV Movie"),
        GenreItem(id: 53, name: "Thriller"),
        GenreItem(id: 10752, name: "War"),
        GenreItem(id: 37, name: "Western")
    ]
    
    static let tvGenres: [GenreItem] = [
        GenreItem(id: 10759, name: "Action & Adventure"),
        GenreItem(id: 16, name: "Animation"),
        GenreItem(id: 35, name: "Comedy"),
        GenreItem(id: 80, name: "Crime"),
        GenreItem(id: 99, name: "Documentary"),
        GenreItem(id: 18, name: "Drama"),
        GenreItem(id: 10751, name: "Family"),
        GenreItem(id: 10762, name: "Kids"),
        GenreItem(id: 9648, name: "Mystery"),
        GenreItem(id: 10763, name: "News"),
        GenreItem(id: 10764, name: "Reality"),
        GenreItem(id: 10765, name: "Sci-Fi & Fantasy"),
        GenreItem(id: 10766, name: "Soap"),
        GenreItem(id: 10767, name: "Talk"),
        GenreItem(id: 10768, name: "War & Politics"),
        GenreItem(id: 37, name: "Western")
    ]
}
