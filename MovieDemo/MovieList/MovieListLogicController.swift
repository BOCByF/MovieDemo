//
//  MovieListLogicController.swift
//  MovieDemo
//
//  Created by Shelton Han on 7/7/2023.
//

import Foundation
import OSLog

struct MovieListCellModel {
    let imageUrl: URL?
    let title: String
    let releaseDate: String
    let reviewScore: String
    let reivewCount: String
    let isFavourite: Bool
}

class MovieListViewModel {
    var searchLabel: String = ""
    var cellModels = [MovieListCellModel]()
    
    func translate(searchLabel: String?, movieItems: [MovieItem], favouriteList: [Int]) {
        if let searchLabel = searchLabel {
            self.searchLabel = searchLabel
        }
        
        cellModels = movieItems.map { item in
            let imageUrl = URL(string: item.posterUrlString)
            let reviewScore = "\(String(format: "%.1f", item.voteAverage)) / 10.0"
            let reivewCount = "\(item.voteCount) Reviews"
            let isFavourite = favouriteList.contains { $0 == item.id }
            return MovieListCellModel(imageUrl: imageUrl, title: item.title, releaseDate: item.releaseDate, reviewScore: reviewScore, reivewCount: reivewCount, isFavourite: isFavourite)
        }
    }
}

enum MovieListNavigationInfo {
    case showDetails(String, Int)
}

class MovieListLogicController: BaseLogicControllerProtocol {
    var viewModel: MovieListViewModel?
    var viewController: MovieListViewController?
    var dataSource: DataSourceInterface?
    
    var cachedMovieItems = [MovieItem]()
    
    required init(viewModel: MovieListViewModel, viewController: MovieListViewController, dataSource: DataSourceInterface) {
        self.viewModel = viewModel
        self.viewController = viewController
        self.dataSource = dataSource
        
        initData()
    }
    
    func initData() {
        self.viewModel?.translate(searchLabel: "", movieItems: [MovieItem](), favouriteList: [Int]())
        refresh(with: self.viewModel)
    }
    
    func search(with query: String?, page: Int) {
        let query = query ?? ""
        
        let favouriteList = dataSource?.fetchFavourites() ?? [Int]()
        dataSource?.fetchMovies(query: query, page: page, { movieList, error in
            if let error = error {
                UniversalErrorHandler.shared.handle(error)
            }
            self.cachedMovieItems = movieList
            self.viewModel?.translate(searchLabel: query, movieItems: movieList, favouriteList: favouriteList)
            self.refresh(with: self.viewModel)
        })
    }
    
    func selectItem(index: Int) {
        let item = self.cachedMovieItems[index]
        self.viewController?.navigate(info:.showDetails("segue_show_details", item.id))
    }
    
    func refreshFavourites() {
        let favouriteList = dataSource?.fetchFavourites() ?? [Int]()
        self.viewModel?.translate(searchLabel: nil, movieItems: self.cachedMovieItems, favouriteList: favouriteList)
        self.refresh(with: self.viewModel)
    }
    
    func refresh(with viewModel: MovieListViewModel?) {
        guard let viewModel = viewModel,
              let viewController = self.viewController else {
            Logger().debug("\(String(describing: self)) unable to refresh(...)")
            return
        }
        DispatchQueue.main.async {
            viewController.refreshView(with: viewModel)
        }
    }
    
}
