//
//  NetworkError.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 21/01/26.
//

import Foundation

struct NetworkError: Error {
    let message: String
    
    static let noInternet = NetworkError(message: "No internet connection. Please check your network.")
    static let serverError = NetworkError(message: "Server error. Please try again later.")
    static let decodingError = NetworkError(message: "Failed to load data. Please try again.")
    static let unknown = NetworkError(message: "An unexpected error occurred.")
}
