//
//  Video.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 21/01/26.
//

import Foundation

struct VideosResponse: Codable {
    let results: [Video]
}

struct Video: Codable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
}
