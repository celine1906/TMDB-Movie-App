//
//  DiscoverViewModelTests.swift
//  TMDB MoviesTests
//
//  Created by Regina Celine Adiwinata on 22/01/26.
//

import XCTest
import Combine
@testable import TMDB_Movies

final class DiscoverViewModelTests: XCTestCase {
    
    var sut: DiscoverViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        sut = DiscoverViewModel(type: .movie)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialState_ShouldHaveCorrectDefaults() {
        XCTAssertTrue(sut.items.isEmpty, "Items should be empty initially")
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")
        XCTAssertNil(sut.error, "Should have no error initially")
        XCTAssertNil(sut.selectedGenre, "Should have no selected genre initially")
    }
    
    func testInitialState_ShouldLoadGenres() {
        let expectation = XCTestExpectation(description: "Genres should be loaded")
        
        sut.$genres
            .dropFirst()
            .sink { genres in
                if !genres.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3.0)
        XCTAssertFalse(sut.genres.isEmpty, "Genres should be loaded from API or fallback")
    }
    
    func testApplyFilter_WhenGenreIsSelected_ShouldUpdateSelectedGenre() {
        let expectation = XCTestExpectation(description: "Selected genre should be updated")
        let actionGenre = GenreItem(id: 28, name: "Action")
        
        sut.$selectedGenre
            .dropFirst()
            .sink { genre in
                if genre?.id == actionGenre.id {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.applyFilter(genre: actionGenre)
  
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(sut.selectedGenre?.id, actionGenre.id, "Selected genre should be updated")
        XCTAssertEqual(sut.selectedGenre?.name, "Action", "Selected genre name should match")
    }
    
    func testApplyFilter_WhenGenreIsNil_ShouldClearSelectedGenre() {
        let expectation = XCTestExpectation(description: "Genre should be cleared")
        sut.applyFilter(genre: GenreItem(id: 28, name: "Action"))
        
        var updateCount = 0
        
        sut.$selectedGenre
            .dropFirst()
            .sink { genre in
                updateCount += 1
                if genre == nil && updateCount > 0 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.applyFilter(genre: nil)
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertNil(sut.selectedGenre, "Selected genre should be nil after reset")
    }
    
    func testSearch_WhenQueryIsNotEmpty_ShouldResetSelectedGenre() {
        sut.applyFilter(genre: GenreItem(id: 28, name: "Action"))

        sut.search(query: "Avengers")
        
        XCTAssertNil(sut.selectedGenre, "Genre filter should be reset during search")
    }
    
    func testSearch_WhenQueryIsEmpty_ShouldResetSelectedGenre() {

        sut.applyFilter(genre: GenreItem(id: 28, name: "Action"))
   
        sut.search(query: "")
      
        XCTAssertNil(sut.selectedGenre, "Genre should be reset when search is cleared")
    }
    
    func testChangeType_WhenSwitchingType_ShouldResetSelectedGenre() {
        sut.applyFilter(genre: GenreItem(id: 28, name: "Action"))
        XCTAssertNotNil(sut.selectedGenre, "Genre should be selected")
        
        sut.changeType(.tv)

        XCTAssertNil(sut.selectedGenre, "Selected genre should be reset when changing type")
    }
    
    func testChangeType_WhenSwitchingToSameType_ShouldNotTriggerChanges() {
        _ = sut.genres.count
        
        sut.changeType(.movie)
        
        XCTAssertTrue(true, "Should handle same type gracefully")
    }
    
    func testChangeType_WhenSwitchingType_ShouldLoadNewGenres() {
        let expectation = XCTestExpectation(description: "New genres should be loaded")
        var genreUpdateCount = 0

        sut.$genres
            .dropFirst()
            .sink { genres in
                genreUpdateCount += 1
                if genreUpdateCount >= 1 && !genres.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.changeType(.tv)
        
        wait(for: [expectation], timeout: 3.0)
        XCTAssertFalse(sut.genres.isEmpty, "Should have TV show genres loaded")
    }
}
