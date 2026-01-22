//
//  PosterPresentable.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 21/01/26.
//

import Foundation

protocol PosterPresentable {
    var id: Int { get }
    var tmdbPosterURL: URL? { get }
    var ratingText: String? { get }
}

extension PosterPresentable {
    func makeTMDBPosterURL(from path: String?) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}
