//
//  SettingsViewController.swift
//  MovieDemo
//
//  Created by Shelton Han on 7/7/2023.
//

import Foundation
import UIKit

class SettingsViewModel {
    var isOfflineMode = false
    
    func transalate(isOffline: Bool) {
        self.isOfflineMode = isOffline
    }
}

class SettingsLogicController: BaseLogicControllerProtocol {
    var viewController: SettingsViewController? = nil
    var viewModel: SettingsViewModel? = nil
    var dataSource: DataSourceInterface?
    
    var cachedIsOffline: Bool = false
    
    required init(viewModel: SettingsViewModel, viewController: SettingsViewController, dataSource: DataSourceInterface) {
        self.viewModel = viewModel
        self.viewController = viewController
        self.dataSource = dataSource
    }
    
    func initData() {
        self.cachedIsOffline = self.dataSource?.fetchSettingsOfflineMode() ?? false
        viewModel?.transalate(isOffline: self.cachedIsOffline)
        viewController?.refreshView(viewModel: viewModel)
    }
    
    func toggleOffline() {
        cachedIsOffline = !cachedIsOffline
        
        SceneDelegate.shared?.dependencyInjection?.toggleDatasource(isOffline: cachedIsOffline)
        viewModel?.transalate(isOffline: self.cachedIsOffline)
        viewController?.refreshView(viewModel: viewModel)
        
        (SceneDelegate.shared?.homeNavController as? HomeNavController)?.updateOfflineButton(show: cachedIsOffline)
    }
}

class SettingsViewController: UIViewController {
    @IBOutlet var offlineSwitch: UISwitch!
    @IBOutlet var ofllineWarningLabel: UILabel!
    
    var logicController: SettingsLogicController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        SceneDelegate.shared?.dependencyInjection?.bind(viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.logicController?.initData()
    }
    
    func bind(logicController: Any) {
        self.logicController = logicController as? SettingsLogicController
    }
    
    func refreshView(viewModel: SettingsViewModel?) {
        guard let viewModel = viewModel else { return }
        offlineSwitch.isOn = viewModel.isOfflineMode
        ofllineWarningLabel.isHidden = !viewModel.isOfflineMode
    }
    
    @IBAction func onOfflineModeChange(_ sender: Any) {
        logicController?.toggleOffline()
    }
    
}

