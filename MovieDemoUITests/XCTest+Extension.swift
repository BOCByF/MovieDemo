//
//  XCTest+Extension.swift
//  MovieDemoUITests
//
//  Created by Shelton Han on 10/7/2023.
//

import Foundation
import XCTest

extension XCTestCase {
    func waitTillAppear(_ format: String = "exists == true", timeout: TimeInterval = 10.0, element: XCUIElement, ignoreFailure: Bool = false, success: (() -> Void)? = nil) {
        let expectation = self.expectation(
            for: NSPredicate(format: format),
            evaluatedWith: element,
            handler: .none
        )
        
        let resultOfExpectation = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        switch resultOfExpectation {
            case .completed:
                success?()
            default:
                if !ignoreFailure {
                    XCTFail("\(String(describing: element)) not found")
                }
        }
    }
}
