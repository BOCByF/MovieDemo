//
//  DependencyInjection.swift
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

// Creation
class DependencyInjection {
    
    private let coreDataAccess: CoreDataAccess
    private let networkAccess: NetworkAccess
    private let mockAccess: MockAccess
    private var dataSource: DataSourceInterface?
    
    private var isOffline: Bool = false
    private var isMock: Bool = false
    
    fileprivate init(defaultPresenter: UIViewController) {
        UniversalErrorHandler.shared.defaultPresenter = defaultPresenter
        
        coreDataAccess = CoreDataAccess()
        networkAccess = NetworkAccess()
        mockAccess = MockAccess()
    }
    
    func bind(viewController: any BaseViewControllerProtocol) {
        switch viewController {
            case is MovieListViewController:
                if let viewController = viewController as? MovieListViewController {
                    let dataSource = getDataSource()
                    let viewModel = MovieListViewModel()
                    let logicController = MovieListLogicController(viewModel: viewModel, viewController: viewController, dataSource: dataSource)
                    
                    viewController.bind(logicController: logicController)
                }
            default:
                return
        }
    }
    
    func toggleDatasource(isOffline: Bool, isMock: Bool) {
        self.isOffline = isOffline
        self.isMock = isMock
    }
    
    func getDataSource() -> DataSourceInterface {
        
        var network = self.isOffline ? nil : networkAccess
        network = self.isMock ? mockAccess : network
        
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
