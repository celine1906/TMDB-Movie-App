//
//  Review.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 21/01/26.
//

import Foundation

struct ReviewsResponse: Codable {
    let results: [Review]
}

struct Review: Codable {
    let id: String
    let author: String
    let content: String
    let createdAt: String
    let authorDetails: AuthorDetails?
    
    enum CodingKeys: String, CodingKey {
        case id, author, content
        case createdAt = "created_at"
        case authorDetails = "author_details"
    }
}

struct AuthorDetails: Codable {
    let rating: Double?
}
