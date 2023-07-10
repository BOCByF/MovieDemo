//
//  MovieDemoTests.swift
//  MovieDemoTests
//
//  Created by Shelton Han on 5/7/2023.
//

import XCTest
@testable import MovieDemo

final class DataProviderTests: XCTestCase {

    var dataSource: DataSourceInterface? = nil
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        SceneDelegate.shared?.dependencyInjection?.toggleDatasource(isOffline: false, isMock: true)
        dataSource = SceneDelegate.shared?.dependencyInjection?.getDataSource()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSearchNotEmpty() throws {
        dataSource?.fetchMovies(query: "John Wick", page: 1, { itemList, error in
            XCTAssertFalse(itemList.isEmpty)
        })
    }
    
    func testSearchEmpty() throws {
        dataSource?.fetchMovies(query: "", page: 1, { itemList, error in
            XCTAssertTrue(itemList.isEmpty)
        })
    }
    
    func testGetMovie() throws {
        dataSource?.fetchMovies(query: "", page: 1, { itemList, error in
            let matchedList = self.dataSource?.fetchMovie(query: "John Wick")
            XCTAssertFalse(matchedList?.isEmpty ?? true)
        })
    }

}
