//
//  UniversalErrorHandler.swift
//  MovieDemo
//
//  Created by Shelton Han on 5/7/2023.
//

import Foundation
import UIKit

class UniversalErrorHandler {
    static let shared: UniversalErrorHandler = UniversalErrorHandler()
    
    var defaultPresenter: UIViewController? = nil
    
    private init() {}
    
    func handle(_ error: String) {
        
    }
    
}
