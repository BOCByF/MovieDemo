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
    #if DEBUG
    private var isMock = CommandLine.arguments.contains("isUITest")
    private var clearLocalCache = CommandLine.arguments.contains("clearCoreData")
    #else
    private var isMock: Bool = false
    #endif
    
    fileprivate init(defaultPresenter: UIViewController) {
        UniversalErrorHandler.shared.defaultPresenter = defaultPresenter
        
        let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        coreDataAccess = CoreDataAccess(managedContext: managedContext)
        self.isOffline = coreDataAccess.fetchSettingsOffline()
        networkAccess = NetworkAccess()
        mockAccess = MockAccess()
    }
    
    func bind(viewController: Any) {
        switch viewController {
            case is FavouriteListViewController:
                if let viewController = viewController as? FavouriteListViewController {
                    let dataSource = getDataSource()
                    let viewModel = MovieListViewModel()
                    let logicController = FavouriteListLogicController(viewModel: viewModel, viewController: viewController, dataSource: dataSource)
                    
                    viewController.bind(logicController: logicController)
                }
            case is MovieListViewController:
                if let viewController = viewController as? MovieListViewController {
                    let dataSource = getDataSource()
                    let viewModel = MovieListViewModel()
                    let logicController = MovieListLogicController(viewModel: viewModel, viewController: viewController, dataSource: dataSource)
                    
                    viewController.bind(logicController: logicController)
                }
            case is MovieDetailsViewController:
                if let viewController = viewController as? MovieDetailsViewController {
                    let dataSource = getDataSource()
                    let viewModel = MovieDetailsViewModel()
                    let logicController = MovieDetailsLogicController(viewModel: viewModel, viewController: viewController, dataSource: dataSource)
                    
                    viewController.bind(logicController: logicController)
                }
            case is SettingsViewController:
                if let viewController = viewController as? SettingsViewController {
                    let dataSource = getDataSource()
                    let viewModel = SettingsViewModel()
                    let logicController = SettingsLogicController(viewModel: viewModel, viewController: viewController, dataSource: dataSource)
                    
                    viewController.bind(logicController: logicController)
                }
            default:
                return
        }
    }
    
    func toggleDatasource(isOffline: Bool? = nil, isMock: Bool? = nil) {
        if let isOffline = isOffline {
            self.isOffline = isOffline
        }
        if let isMock = isMock {
            self.isMock = isMock
        }
        #if DEBUG
        if clearLocalCache {
            coreDataAccess.clearCoreData()
        }
        #endif
        
        // Commit change
        _ = getDataSource()
    }
    
    func getDataSource() -> DataSourceInterface {
        var network = self.isOffline ? nil : networkAccess
        network = self.isMock ? mockAccess : network
        
        if let dataSourceImp = self.dataSource {
            dataSourceImp.toggleRemoteAccess(with: network)
            return dataSourceImp
        } else {
            let dataSourceImp = DataSourceImp(restore: coreDataAccess, network: network)
            self.dataSource = dataSourceImp
            return dataSourceImp
        }
    }
    
}
