//
//  DataSourceInterface.swift
//  MovieDemo
//
//  Created by Shelton Han on 5/7/2023.
//

import Foundation
//import Math

// Mock
struct MovieItem {
    let id: Int
    let title: String
    let fetchTimestamp: Double
    let releaseDate: String
    let posterUrlString: String
    let voteAverage: Double
    let voteCount: Int
    let overview: String
}

protocol DataSourceInterface {
    // MovieList
    func fetchMovie(id: Int) -> [MovieItem]
    func fetchMovie(query: String) -> [MovieItem]
    func fetchMovies(query: String, page: Int, _ completion: @escaping MovieListCompletion)
    // Favourite
    func fetchFavourites() -> [Int]
    func toggleFavourite(id: Int)
    // Settings
    func fetchSettingsOfflineMode() -> Bool
    func toggleRemoteAccess(with remote: NetworkAccess?)
}
