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
    static let cellHeight:Double = 200.0
    
    @IBOutlet var posterImage: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var releaseDate: UILabel!
    @IBOutlet var reviewScore: UILabel!
    @IBOutlet var reviewCount: UILabel!
    @IBOutlet var heartIcon: UIImageView!
    
    func refresh(with cellModel: MovieListCellModel) {
        posterImage.sd_imageIndicator = SDWebImageActivityIndicator.white
        posterImage.sd_setImage(with: cellModel.imageUrl)
        title.text = cellModel.title
        releaseDate.text = cellModel.releaseDate
        reviewScore.text = cellModel.reviewScore
        reviewCount.text = cellModel.reivewCount
        heartIcon.isHidden = !cellModel.isFavourite
        
        heartIcon.accessibilityIdentifier = "search:image:heart"
    }
}

/// Search and show a list of movies
///
/// - LC: MovieListLogicController
/// - VM: MovieListViewModel
class MovieListViewController: UIViewController {
    @IBOutlet var searchBar: UISearchBar? = nil
    @IBOutlet var movieTableView: UITableView!
    @IBOutlet var movieResultLabel: UILabel? = nil
    @IBOutlet var emptyMessageLabel: UILabel!

    private var movieListLogicController: MovieListLogicController? = nil
    var logicController: MovieListLogicController? {
        return movieListLogicController
    }
    
    var viewModel: MovieListViewModel?
    
    var navigationInfo: MovieListNavigationInfo? = nil
    var cachedScrollIndex = 0
    var pauseScrollListening = false
    
    func bind(logicController: Any) {
        self.movieListLogicController = logicController as? MovieListLogicController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SceneDelegate.shared?.dependencyInjection?.bind(viewController: self)
        
        setupAccessibilityIdentifiers()
    }
    
    func setupAccessibilityIdentifiers() {
        searchBar?.accessibilityIdentifier = "search:searchBar:searchBar"
        emptyMessageLabel?.accessibilityIdentifier = "search:label:emptyMessage"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar?.delegate = self
        
        logicController?.refreshFavourites()
    }
    
    func navigate(info: MovieListNavigationInfo) {
        navigationInfo = info
        switch info {
            case .showDetails(let segueId, _):
                performSegue(withIdentifier: segueId, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationInfo = navigationInfo else { return }
        switch navigationInfo {
            case .showDetails(let segueId, let itemId):
                if segue.identifier == segueId,
                   let destination = segue.destination as? MovieDetailsViewController {
                    destination.presetItemId = itemId
                }
        }
    }
    
    func refreshView(with viewModel: MovieListViewModel) {
        self.viewModel = viewModel
        self.movieResultLabel?.isHidden = viewModel.cellModels.isEmpty
        self.emptyMessageLabel.isHidden = !viewModel.cellModels.isEmpty
        self.searchBar?.text = viewModel.searchLabel
        self.fixedPosReload(tableView: self.movieTableView)
    }

}

extension MovieListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.movieTableView.contentOffset = CGPoint.zero
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

extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        logicController?.selectItem(index: indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !pauseScrollListening else { return }
        
        let contentOffsetY = self.movieTableView.contentOffset.y
        let scrollIndex = Int((contentOffsetY / MovieListCell.cellHeight).rounded(.up))
        if scrollIndex != cachedScrollIndex {
            cachedScrollIndex = scrollIndex
            logicController?.searchPaging(with: searchBar?.text, currentScrollIndex: scrollIndex)
        }
    }
}

/// Try the best to reload table while maintaining the scrolling postition
extension MovieListViewController {
    func fixedPosReload(tableView: UITableView) {
        self.pauseScrollListening = true
        let contentOffset = tableView.contentOffset
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.setContentOffset(contentOffset, animated: false)
        self.pauseScrollListening = false
    }
}
















