//
//  BaseViewController.swift
//  MovieDemo
//
//  Created by Shelton Han on 7/7/2023.
//

import Foundation
import UIKit
import OSLog

protocol BaseViewControllerProtocol {
    associatedtype LC: BaseLogicControllerProtocol
    associatedtype VM: Any
    
    var logicController: LC? { get }
    
    func bind(logicController: LC)
    func refreshView(with viewModel: VM)
}


protocol BaseLogicControllerProtocol {
    associatedtype VC: BaseViewControllerProtocol
    associatedtype VM: Any
    
    var viewModel: VM? { get }
    var viewController: VC? { get }
    var dataSource: DataSourceInterface? { get }
    
    init(viewModel: VM, viewController: VC, dataSource: DataSourceInterface)
}


