//
//  UniversalErrorHandler.swift
//  MovieDemo
//
//  Created by Shelton Han on 5/7/2023.
//

import Foundation
import UIKit
import Toast_Swift
import OSLog

class UniversalErrorHandler {
    static let shared: UniversalErrorHandler = UniversalErrorHandler()
    
    var defaultPresenter: UIViewController? = nil
    
    private init() {}
    
    func handle(_ errorMessage: String, presenter: UIViewController? = nil) {
        guard let presenter = presenter ?? defaultPresenter else {
            Logger().debug("\(String(describing: self)) found no presenter")
            return
        }
        presenter.view.makeToast(errorMessage, duration: 3.0, position: .top)
    }
}
