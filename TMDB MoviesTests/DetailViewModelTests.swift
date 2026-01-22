//
//  DetailViewModelTests.swift
//  TMDB MoviesTests
//
//  Created by Regina Celine Adiwinata on 22/01/26.
//

import XCTest
import Combine
@testable import TMDB_Movies

final class DetailViewModelTests: XCTestCase {
    
    var movieViewModel: DetailViewModel!
    var tvViewModel: DetailViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        movieViewModel = DetailViewModel(id: 123, type: .movie)
        tvViewModel = DetailViewModel(id: 456, type: .tv)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        movieViewModel = nil
        tvViewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testDisplayTitle_ForMovie_ShouldIncludeYearInParentheses() {
        let mockMovie = MovieDetail(
            id: 123,
            title: "The Avengers",
            overview: "Earth's mightiest heroes",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2012-05-04",
            voteAverage: 8.0,
            runtime: 143,
            genres: [Genre(id: 28, name: "Action")],
            tagline: "Some assembly required"
        )
        
        movieViewModel.movieDetail = mockMovie
        
        let displayTitle = movieViewModel.displayTitle
        XCTAssertEqual(displayTitle, "The Avengers (2012)", "Display title should include year")
    }
    
    func testDisplayTitle_ForTVShow_ShouldIncludeYearInParentheses() {
        let mockTV = TVShowDetail(
            id: 456,
            name: "Breaking Bad",
            overview: "A chemistry teacher turns to cooking meth",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            firstAirDate: "2008-01-20",
            voteAverage: 9.3,
            episodeRunTime: [47],
            genres: [TVGenre(id: 18, name: "Drama")],
            tagline: "Chemistry is the study of change"
        )
        
        tvViewModel.tvDetail = mockTV
        
        let displayTitle = tvViewModel.displayTitle
        XCTAssertEqual(displayTitle, "Breaking Bad (2008)", "Display title should include year")
    }
    
    func testDisplayTitle_WithInvalidDate_ShouldReturnTitleWithoutYear() {
        let mockMovie = MovieDetail(
            id: 123,
            title: "Unknown Movie",
            overview: "No release date",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "",
            voteAverage: 0,
            runtime: nil,
            genres: [],
            tagline: nil
        )
        
        movieViewModel.movieDetail = mockMovie
        
        let displayTitle = movieViewModel.displayTitle
        XCTAssertEqual(displayTitle, "Unknown Movie", "Should return title without year for invalid date")
    }
    
    func testInfoText_ForMovieWithRuntime_ShouldCombineRatingAndRuntime() {

        let mockMovie = MovieDetail(
            id: 123,
            title: "Test Movie",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "2024-01-01",
            voteAverage: 7.8,
            runtime: 142,
            genres: [],
            tagline: nil
        )
        
        movieViewModel.movieDetail = mockMovie
        
        let infoText = movieViewModel.infoText
        XCTAssertTrue(infoText.contains("7.8"), "Info text should contain rating")
        XCTAssertTrue(infoText.contains("2h 22m"), "Info text should contain runtime")
        XCTAssertTrue(infoText.contains("•"), "Info text should contain bullet separator")
    }
    
    func testInfoText_ForTVShow_ShouldShowEpisodeRuntime() {
        let mockTV = TVShowDetail(
            id: 456,
            name: "Test Show",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            firstAirDate: "2024-01-01",
            voteAverage: 8.5,
            episodeRunTime: [45],
            genres: [],
            tagline: nil
        )
        tvViewModel.tvDetail = mockTV
        
        let infoText = tvViewModel.infoText
        XCTAssertTrue(infoText.contains("8.5"), "Info text should contain rating")
        XCTAssertTrue(infoText.contains("45m / episode"), "Info text should show episode runtime")
    }
    
    func testRatingText_ShouldFormatToOneDecimalPlace() {
        let mockMovie = MovieDetail(
            id: 123,
            title: "Test",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "2024-01-01",
            voteAverage: 7.856,
            runtime: 120,
            genres: [],
            tagline: nil
        )
        
        movieViewModel.movieDetail = mockMovie
        
        let rating = movieViewModel.ratingText
        XCTAssertEqual(rating, "7.9", "Rating should be formatted to 1 decimal place")
    }
    
    
    func testGenresText_ForMovie_ShouldJoinWithComma() {
        let mockMovie = MovieDetail(
            id: 123,
            title: "Test",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "2024-01-01",
            voteAverage: 7.0,
            runtime: 120,
            genres: [
                Genre(id: 28, name: "Action"),
                Genre(id: 12, name: "Adventure"),
                Genre(id: 878, name: "Science Fiction")
            ],
            tagline: nil
        )
        movieViewModel.movieDetail = mockMovie
        
        let genresText = movieViewModel.genresText
        XCTAssertEqual(genresText, "Action, Adventure, Science Fiction", "Genres should be joined with comma and space")
    }
    
    func testGenresText_ForTVShow_ShouldJoinWithComma() {
        let mockTV = TVShowDetail(
            id: 456,
            name: "Test Show",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            firstAirDate: "2024-01-01",
            voteAverage: 8.0,
            episodeRunTime: [45],
            genres: [
                TVGenre(id: 18, name: "Drama"),
                TVGenre(id: 80, name: "Crime")
            ],
            tagline: nil
        )
        
        tvViewModel.tvDetail = mockTV
        
        let genresText = tvViewModel.genresText
        XCTAssertEqual(genresText, "Drama, Crime", "Genres should be joined with comma and space")
    }
}
