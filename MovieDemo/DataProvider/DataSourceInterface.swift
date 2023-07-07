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
    let timestamp: Double
}

protocol DataSourceInterface {
    func toggleRemoteAccess(with remote: NetworkAccess?)
    func fetchMovie(query: String) -> [MovieItem]
    func fetchMovies(query: String, page: Int, _ completion: MovieListCompletion)
    
}
