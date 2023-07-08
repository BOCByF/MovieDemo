//
//  MovieDetailsViewController.swift
//  MovieDemo
//
//  Created by Shelton Han on 7/7/2023.
//

import Foundation
import UIKit
import SDWebImage

/// Show details of a movie
///
/// - LC: MovieDetailsLogicController
/// - VM: MovieDetailsViewModel
class MovieDetailsViewController: UIViewController, BaseViewControllerProtocol {
    @IBOutlet var posterImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var releaseDateLabel: UILabel!
    @IBOutlet var reviewScoreLabel: UILabel!
    @IBOutlet var reviewCountLabel: UILabel!
    @IBOutlet var faviouriteButton: UIButton!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var shadowView: UIView!
    
    var logicController: MovieDetailsLogicController?
    var viewModel: MovieDetailsViewModel?
    
    var presetItemId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SceneDelegate.shared?.dependencyInjection?.bind(viewController: self)
        
        // Add shadow layer
        let shadowGradientLayer = CAGradientLayer()
        shadowGradientLayer.frame = shadowView.bounds
        shadowGradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        shadowGradientLayer.locations = [0.0, 1.0]
        shadowView.layer.insertSublayer(shadowGradientLayer, at: 0)
    }
    
    func bind(logicController: MovieDetailsLogicController) {
        self.logicController = logicController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let itemId = presetItemId {
            logicController?.loadMovie(id: itemId)
        }
    }
    
    func refreshView(with viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
        
        self.posterImage.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
        self.posterImage.sd_setImage(with: viewModel.imageUrl)
        self.titleLabel.text = viewModel.title
        self.releaseDateLabel.text = viewModel.releaseDate
        self.reviewScoreLabel.text = viewModel.reviewScore
        self.reviewCountLabel.text = viewModel.reivewCount
        self.overviewLabel.text = viewModel.overview
        let favouriteButtonImageName = viewModel.isFavourite ? "heart.fill" : "heart"
        self.faviouriteButton.setImage(UIImage(systemName: favouriteButtonImageName), for: .normal)
    }
    
    @IBAction func onFavouriteButton(_ sender: Any) {
        if let id = presetItemId {
            logicController?.toggleFavourite(id: id)
        }
    }
    
}
