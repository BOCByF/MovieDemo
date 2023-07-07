//
//  MovieListViewController.swift
//  MovieDemo
//
//  Created by Shelton Han on 5/7/2023.
//

import UIKit
import SDWebImage

class MovieListCell: UITableViewCell {
    static let identifier = "identifier_movieListCell"
    
    @IBOutlet var posterImage: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var releaseDate: UILabel!
    @IBOutlet var reviewScore: UILabel!
    @IBOutlet var reviewCount: UILabel!
    
    func refresh(with cellModel: MovieListCellModel) {
        posterImage.sd_imageIndicator = SDWebImageActivityIndicator.white
        posterImage.sd_setImage(with: cellModel.imageUrl)
        title.text = cellModel.title
        releaseDate.text = cellModel.releaseDate
        reviewScore.text = cellModel.reviewScore
        reviewCount.text = cellModel.reivewCount
    }
}

/// Search and show a list of movies
///
/// - LC: MovieListLogicController
/// - VM: MovieListViewModel
class MovieListViewController: UIViewController, BaseViewControllerProtocol {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var movieTableView: UITableView!
    @IBOutlet var movieResultLabel: UILabel!
    @IBOutlet var emptyMessageLabel: UILabel!

    var logicController: MovieListLogicController?
    var viewModel: MovieListViewModel?
    
    func bind(logicController: MovieListLogicController) {
        self.logicController = logicController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SceneDelegate.shared?.dependencyInjection?.bind(viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.delegate = self
        
        self.logicController?.initData()
    }
    
    func refreshView(with viewModel: MovieListViewModel) {
        self.viewModel = viewModel
        self.movieResultLabel.isHidden = viewModel.cellModels.isEmpty
        self.emptyMessageLabel.isHidden = !viewModel.cellModels.isEmpty
        self.searchBar.text = viewModel.searchLabel
        self.movieTableView.reloadData()
    }

}

extension MovieListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        logicController?.search(with: searchBar.text, page: 1)
    }
}

extension MovieListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.cellModels.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieListCell.identifier, for: indexPath) as? MovieListCell
        if let cellModel = self.viewModel?.cellModels[indexPath.row] {
            cell?.refresh(with: cellModel)
        }
        
        return cell ?? UITableViewCell()
    }
    
}
