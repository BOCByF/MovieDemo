//
//  DataSourceInterface.swift
//  MovieDemo
//
//  Created by Shelton Han on 5/7/2023.
//

import Foundation

// Mock
struct MovieItem {
    let title: String
    let timestamp: String
}

protocol DataSourceInterface {
    func fetchMovie(query: String) -> MovieItem?
    func fetchMovies(query: String, page: Int) -> [MovieItem]?
    
}
