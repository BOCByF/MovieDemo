//
//  UniversalLink.swift
//  MovieDemo
//
//  Created by Shelton Han on 5/7/2023.
//

import Foundation
import UIKit

class DependencyInjection {
    static let shared: DependencyInjection = DependencyInjection()
    
    
    private init() {}
    
}

class UniversalLink {
    static let shared: UniversalLink = UniversalLink()
    
    var defaultPresenter: UIViewController? = nil
    
    private init() {}
    
    func handle(_ link: String, presenter: UIViewController? = nil) {
        
        
    }
}
