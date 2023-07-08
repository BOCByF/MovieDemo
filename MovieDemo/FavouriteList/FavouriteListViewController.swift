//
//  FavouriteListViewController.swift
//  MovieDemo
//
//  Created by Shelton Han on 8/7/2023.
//

import Foundation
import UIKit

class FavouriteListLogicController: MovieListLogicController {
    override func refreshFavourites() {
        let favouriteList = dataSource?.fetchFavourites() ?? [Int]()
        var favouriteMovies = [MovieItem]()
        favouriteList.forEach { id in
            if let matchedItem = self.dataSource?.fetchMovie(id: id).first {
                favouriteMovies.append(matchedItem)
            }
        }
        self.cachedMovieItems = favouriteMovies
        
        self.viewModel?.translate(searchLabel: nil, movieItems: self.cachedMovieItems, favouriteList: favouriteList)
        self.refresh(with: self.viewModel)
    }
    
    override func searchPaging(with query: String?, currentScrollIndex: Int) {}  // Disable paging
}

class FavouriteListViewController: MovieListViewController {
    var favouriteListLogicController: FavouriteListLogicController? = nil
    
    override var logicController: MovieListLogicController? {
        return favouriteListLogicController
    }

    override func bind(logicController: Any) {
        self.favouriteListLogicController = logicController as? FavouriteListLogicController
    }
}
