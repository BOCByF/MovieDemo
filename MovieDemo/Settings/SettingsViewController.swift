//
//  SettingsViewController.swift
//  MovieDemo
//
//  Created by Shelton Han on 7/7/2023.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    var isOffline = false
    
    @IBOutlet var offlineSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isOffline = SceneDelegate.shared?.isOffline ?? false
        offlineSwitch.isOn = isOffline
    }
    
    @IBAction func onOfflineModeChange(_ sender: Any) {
        isOffline = !isOffline
        SceneDelegate.shared?.dependencyInjection?.toggleDatasource(isOffline: isOffline)
    }
    
}

