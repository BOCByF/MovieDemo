//
//  SearchUITests.swift
//  MovieDemoUITests
//
//  Created by Shelton Han on 5/7/2023.
//

import XCTest
@testable import MovieDemo

final class SearchUITests: BaseUITestCase {
    /*
     SV-001: Search with empty message
     Given user opens app

     When user does not enter any search query

     Then app should show message "Start by enter a movie name in the search bar"
     */
    func testEmptyMessage() throws {
        let elementsQuery = app!.otherElements
        let emptyLabel = elementsQuery.staticTexts["Start by enter a movie name in the search bar"]
        waitTillAppear(element: emptyLabel)
    }
    
    /*
     SV-002: Search with list of movies
     Given user opens app

     When user enter search query "Jo"

     Then app show a list of movies with "Jo" in the name
     */
    func testSearch() throws {
        app!/*@START_MENU_TOKEN@*/.searchFields["Search any movie..."]/*[[".otherElements[\"search:searchBar:searchBar\"].searchFields[\"Search any movie...\"]",".searchFields[\"Search any movie...\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let jKey = app!/*@START_MENU_TOKEN@*/.keys["J"]/*[[".keyboards.keys[\"J\"]",".keys[\"J\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        waitTillAppear(element: jKey)
        jKey.tap()
        let oKey = app!/*@START_MENU_TOKEN@*/.keys["o"]/*[[".keyboards.keys[\"o\"]",".keys[\"o\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        waitTillAppear(element: oKey)
        oKey.tap()
        let searchKey = app!/*@START_MENU_TOKEN@*/.buttons["search"]/*[[".keyboards",".buttons[\"search\"]",".buttons[\"Search\"]"],[[[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        waitTillAppear(element: searchKey)
        searchKey.tap()
        
        let elementsQuery = app!.otherElements
        let existlabel = elementsQuery.staticTexts["Johnny"]
        waitTillAppear(element: existlabel)
    }
    
    /*
     SV-004: Add favourite movie
     Given user opens app

     And user search with a query

     And user select a movie for details

     And user click on favourite button

     When user click on back button

     Then app shows the movie with favourite button
     */
    func testAddFavourite() {
        app!/*@START_MENU_TOKEN@*/.searchFields["Search any movie..."]/*[[".otherElements[\"search:searchBar:searchBar\"].searchFields[\"Search any movie...\"]",".searchFields[\"Search any movie...\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let jKey = app!/*@START_MENU_TOKEN@*/.keys["J"]/*[[".keyboards.keys[\"J\"]",".keys[\"J\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        jKey.tap()
        let oKey = app!/*@START_MENU_TOKEN@*/.keys["o"]/*[[".keyboards.keys[\"o\"]",".keys[\"o\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        oKey.tap()
        let searchKey = app!/*@START_MENU_TOKEN@*/.buttons["search"]/*[[".keyboards",".buttons[\"search\"]",".buttons[\"Search\"]"],[[[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        waitTillAppear(element: searchKey)
        searchKey.tap()
        let elementsQuery = app!.otherElements
        let matchedLabel = elementsQuery.staticTexts["John Wick: Chapter 4"].firstMatch
        waitTillAppear(element: matchedLabel)
        matchedLabel.tap()
        let favouriteButton = app!.buttons["love"]
        waitTillAppear(element: favouriteButton)
        favouriteButton.tap()
        let backButton = app!.navigationBars["HomeNavController"].buttons["Search"]
        backButton.tap()
        let loveIcon = app!.images.matching(identifier: "search:image:heart").firstMatch
        waitTillAppear(element: loveIcon)
    }
    
}


