//
//  MovieDetailsLogicController.swift
//  MovieDemo
//
//  Created by Shelton Han on 7/7/2023.
//

import Foundation
import OSLog

class MovieDetailsViewModel {
    var imageUrl: URL? = nil
    var title: String = ""
    var releaseDate: String = ""
    var reviewScore: String = ""
    var reivewCount: String = ""
    var overview: String = ""
    var isFavourite: Bool = false
    
    func translate(item: MovieItem, favouriteList: [Int]) {
        imageUrl = URL(string: item.posterUrlString)
        title = item.title
        releaseDate = item.releaseDate
        reviewScore = "\(String(format: "%.1f", item.voteAverage)) / 10.0"
        reivewCount = "\(item.voteCount) Reviews"
        overview = item.overview
        isFavourite = favouriteList.contains { $0 == item.id }
    }
}

class MovieDetailsLogicController: BaseLogicControllerProtocol {
    var viewModel: MovieDetailsViewModel?
    var viewController: MovieDetailsViewController?
    var dataSource: DataSourceInterface?
    
    required init(viewModel: MovieDetailsViewModel, viewController: MovieDetailsViewController, dataSource: DataSourceInterface) {
        self.viewModel = viewModel
        self.viewController = viewController
        self.dataSource = dataSource
    }
    
    func loadMovie(id: Int) {
        if let item = dataSource?.fetchMovie(id: id).first,
           let favouriteList = dataSource?.fetchFavourites(){
            self.viewModel?.translate(item: item, favouriteList: favouriteList)
            refresh(with: self.viewModel)
        }
    }
    
    func toggleFavourite(id: Int) {
        self.dataSource?.toggleFavourite(id: id)
        loadMovie(id: id)
    }
    
    func refresh(with viewModel: MovieDetailsViewModel?) {
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
