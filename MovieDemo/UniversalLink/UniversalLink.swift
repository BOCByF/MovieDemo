//
//  UniversalLink.swift
//  MovieDemo
//
//  Created by Shelton Han on 5/7/2023.
//

import Foundation
import UIKit

extension SceneDelegate {
    func createDependencyInjection(_ defaultPresenter: UIViewController) -> DependencyInjection {
        return DependencyInjection(defaultPresenter: defaultPresenter)
    }
}

class DependencyInjection {
    
    private let coreDataAccess: CoreDataAccess
    private let networkAccess: NetworkAccess
    private let mockAccess: MockAccess
    private var dataSource: DataSourceInterface?
    
    fileprivate init(defaultPresenter: UIViewController) {
        UniversalLink.shared.defaultPresenter = defaultPresenter
        UniversalErrorHandler.shared.defaultPresenter = defaultPresenter
        
        coreDataAccess = CoreDataAccess()
        networkAccess = NetworkAccess()
        mockAccess = MockAccess()
    }
    
    func getDataSource(isOffline: Bool, isMock: Bool = false) -> DataSourceInterface {
        var network = isOffline ? nil : networkAccess
        network = isMock ? mockAccess : network
        
        if let dataSourceImp = self.dataSource {
            self.dataSource?.toggleRemoteAccess(with: network)
            return dataSourceImp
        } else {
            let dataSourceImp = DataSourceImp(restore: coreDataAccess, network: network)
            self.dataSource = dataSourceImp
            return dataSourceImp
        }
    }
    
}

class UniversalLink {
    static let shared: UniversalLink = UniversalLink()
    
    var defaultPresenter: UIViewController? = nil
    
    private init() {}
    
    func handle(_ link: String, presenter: UIViewController? = nil) {
        
        
    }
}
