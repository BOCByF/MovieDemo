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
    enum Style {
        case warning
        case error
    }
    
    static let shared: UniversalErrorHandler = UniversalErrorHandler()
    
    var defaultPresenter: UIViewController? = nil
    
    private init() {}
    
    func handle(_ errorMessage: String, presenter: UIViewController? = nil, style: UniversalErrorHandler.Style = .error) {
        guard let presenter = presenter ?? defaultPresenter else {
            Logger().debug("\(String(describing: self)) found no presenter")
            return
        }
        var customStyle = ToastManager.shared.style
        customStyle.backgroundColor = style == .error ? .systemRed : .systemYellow
        presenter.view.makeToast(errorMessage, duration: 3.0, position: .top, style: customStyle)
    }
}
