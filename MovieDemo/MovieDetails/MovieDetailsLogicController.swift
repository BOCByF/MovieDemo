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
    
    func translate(item: MovieItem) {
        imageUrl = URL(string: item.posterUrlString)
        title = item.title
        releaseDate = item.releaseDate
        reviewScore = "\(String(format: "%.1f", item.voteAverage)) / 10.0"
        reivewCount = "\(item.voteCount) Reviews"
        overview = item.overview
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
        if let item = dataSource?.fetchMovie(id: id).first {
            self.viewModel?.translate(item: item)
            refresh(with: self.viewModel)
        }
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
