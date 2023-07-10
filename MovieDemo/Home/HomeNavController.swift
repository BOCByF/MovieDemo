//
//  HomeNavController.swift
//  MovieDemo
//
//  Created by Shelton Han on 6/7/2023.
//

import Foundation
import UIKit

protocol BaseLogicControllerProtocol {
    associatedtype VC: Any
    associatedtype VM: Any
    
    var viewModel: VM? { get }
    var viewController: VC? { get }
    var dataSource: DataSourceInterface? { get }
    
    init(viewModel: VM, viewController: VC, dataSource: DataSourceInterface)
}

class HomeNavController: UINavigationController {
    override var tabBarController: UITabBarController? {
        return viewControllers.first { $0  is UITabBarController }  as? UITabBarController
    }
    
    let offlineBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "desktopcomputer.trianglebadge.exclamationmark"), style: .plain, target: nil, action: #selector(HomeNavController.showSettingsTab(_:)))
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let tabBarController = tabBarController {
            tabBarController.delegate = self
            tabBarController.navigationItem.title = tabBarController.viewControllers?[tabBarController.selectedIndex].navigationItem.title
            
            let isOfflineMode =  SceneDelegate.shared?.dependencyInjection?.getDataSource().fetchSettingsOfflineMode() ?? false
            updateOfflineButton(show: isOfflineMode)
            
        }
    }
    
    func updateOfflineButton(show: Bool) {
        tabBarController?.navigationItem.rightBarButtonItem = show ? offlineBarButtonItem : nil
    }
    
    @objc
    func showSettingsTab(_ sender: Any) {
        tabBarController?.selectedViewController = tabBarController?.viewControllers?.last
    }
    
}

extension HomeNavController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.tabBarController?.navigationItem.title = viewController.navigationItem.title
    }
}




































