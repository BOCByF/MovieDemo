//
//  BaseUITest.swift
//  MovieDemoUITests
//
//  Created by Shelton Han on 11/7/2023.
//

import Foundation
import XCTest

class BaseUITestCase: XCTestCase {
    var app: XCUIApplication? = XCUIApplication()
    var launchArguments: [String] = ["isUITest", "clearCoreData"]

    override func setUpWithError() throws {
        continueAfterFailure = false
        app!.launchArguments = launchArguments
        app!.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
}
