//
//  DataSourceAccess.swift
//  MovieDemo
//
//  Created by Shelton Han on 5/7/2023.
//

import Foundation

typealias MovieListCompletion = ([MovieItem], String?) -> Void

class CoreDataAccess {
    func fetchMovieList() -> [MovieItem] {
        let movieList = [MovieItem]()
        // TODO: Append movie items from CoreData
        return movieList
    }
    
    func persist(list: [MovieItem]) {
        // TODO: Update CoreData
    }
}

class NetworkAccess {
    static let imageHost = "https://image.tmdb.org/t/p/w500"
    static let apiHost = "https://api.themoviedb.org/3"
    static let fixedParams = "include_adult=false&language=en-US"
    static let authToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmYjg4NTI1OWQzYTNmYmFjMWEyMDU2ODVjYTkyNzFkMiIsInN1YiI6IjY0YTRjMTEzMWJmMjY2MDBjNzg5YmUxNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.FQJiaJYn3UuchSPVfqqsah6DY1u3aMKjgUKKrtiOMwE"
    static let sharedSession = URLSession(configuration: .default)
    
    func fetchMovieList(query: String, page: Int, _ completion: @escaping MovieListCompletion) {
        var movieList = [MovieItem]()
        if let request = buildUrlRequest(query: query, page: page) {
            NetworkAccess.sharedSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(movieList, nil)
                    UniversalErrorHandler.shared.handle(error.localizedDescription)
                }
                if let data = data {
                    let parsedMovieItems = self.parseMovieItems(data: data)
                    movieList.append(contentsOf: parsedMovieItems)
                    completion(movieList, nil)
                }
            }.resume()
        }
        completion(movieList, nil)
    }
}

extension NetworkAccess {
    enum APIPath: String {
        case search = "/search/movie"
    }
    
    enum APIParam: String {
        case page = "page"
        case query = "query"
    }
    
    func buildUrlRequest(query: String, page: Int) -> URLRequest? {
        let params = buildMovieSearchAPIParams(query: query, page: page)
        let urlString = "\(NetworkAccess.apiHost)\(NetworkAccess.APIPath.search.rawValue)?\(params)"
        let bearerAuth = "Bearer \(NetworkAccess.authToken)"
        
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            // HTTP Headers are unlikely to change
            request.httpMethod = "GET"
            request.addValue(bearerAuth, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return request
        }
        return nil
    }
    
    func buildMovieSearchAPIParams(query: String, page: Int) -> String {
        let urlAllowed: CharacterSet =
            .alphanumerics.union(.init(charactersIn: "-._~"))
        let queryComponents: [String] = [APIParam.query.rawValue, query.addingPercentEncoding(withAllowedCharacters: urlAllowed) ?? ""]
        let queryParam = queryComponents.joined(separator: "=")
        
        let pageParam = [APIParam.page.rawValue, "\(page)"].joined(separator: "=")
        
        return [NetworkAccess.fixedParams, queryParam, pageParam].joined(separator: "&")
    }
    
    func parseMovieItems(data: Data) -> [MovieItem] {
        var movieList = [MovieItem]()
        if let jsonDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let resultList = jsonDict["results"] as? [[String: Any]] {
            resultList.forEach { item in
                let fetchTimestamp = Date().timeIntervalSince1970.rounded()
                if let id = item["id"] as? Int,
                   let title = item["original_title"] as? String,
                   let releaseDate = item["release_date"] as? String,
                   let posterPath = item["poster_path"] as? String,
                   let voteAverage = item["vote_average"] as? Double,
                   let voteCount = item["vote_count"] as? Int,
                   let overview = item["overview"] as? String
                {
                    let posterUrlString = "\(NetworkAccess.imageHost)\(posterPath)"
                    let voteAverage = voteAverage.rounded()
                    movieList.append(MovieItem(id: id, title: title, fetchTimestamp: fetchTimestamp, releaseDate: releaseDate, posterUrlString: posterUrlString, voteAverage: voteAverage, voteCount: voteCount, overview: overview))
                }
            }
        }
        return movieList
    }
}

class MockAccess: NetworkAccess {
    enum MockFile: String {
        case searchJohnP1 = "search_john_p1"
    }
    
    func fetchMock(with filename: String) -> [MovieItem] {
        var movieList = [MovieItem]()
        if let url = Bundle.main.url(forResource: filename, withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let parsedMovieItems = parseMovieItems(data: data)
            movieList.append(contentsOf: parsedMovieItems)
        }
        return movieList
    }
    
    override func fetchMovieList(query: String, page: Int, _ completion: @escaping MovieListCompletion) {
        let mockList = fetchMock(with: MockFile.searchJohnP1.rawValue)
        completion(mockList, nil)
    }
}

class DataSourceImp: DataSourceInterface {
    static let cacheExpiryThreshhold: Double = 120   // Cache expire in 120 seconds
    
    var persistentStore: CoreDataAccess? = nil
    var networkSource: NetworkAccess? = nil
    
    // Complete dataSource cache
    var cachedMovieList = [MovieItem]()
    var cachedFavouriteList = [Int]()
    
    /// Depending on the restore point, preload data
    init(restore: CoreDataAccess?, network: NetworkAccess?) {
        persistentStore = restore
        if let list = restore?.fetchMovieList() {
            cachedMovieList = list
        }
        networkSource = network
    }
    
    // Used by settings.offlineMode
    func toggleRemoteAccess(with remote: NetworkAccess?) {
        networkSource = remote
    }
    
    func fetchMovie(id: Int) -> [MovieItem] {
        return cachedMovieList.filter { item in
            item.id == id
        }
    }
    
    func fetchMovie(query: String) -> [MovieItem] {
        return cachedMovieList.filter { item in
            item.title.contains(query)
        }
    }
    
    /// Fetch a list of movies from remote and update local persistent store
    ///
    /// Pseudocode:
    /// - Fetch cachedItems per query
    /// - Check on timestemps of cachedMovieList's items
    ///     - expired, moreThan threshold && has remote
    ///         - fetch from remote
    ///             - update local cache
    ///             - update persistentStore
    ///             - completion with cache
    ///     - valid, lessThan threshold || no remote
    ///         - completion with cache
    ///
    ///
    func fetchMovies(query: String, page: Int, _ completion: @escaping MovieListCompletion) {
        let cachedList = fetchMovie(query: query)
        if isCacheExpired(cachedList), let networkSource = networkSource {
            networkSource.fetchMovieList(query: query, page: page) { list, errorMessage in
                if let errorMessage = errorMessage {
                    completion(cachedList, errorMessage)
                } else {    // new data fetched from remote
                    self.mergeCache(with: list)
                    self.refreshPersistentStore(with: self.cachedMovieList)
                    let refreshedCachedList = self.fetchMovie(query: query)
                    completion(refreshedCachedList, nil)
                }
            }
        } else {
            completion(cachedList, nil)
        }
    }
    
    func fetchFavourites() -> [Int] {
        return cachedFavouriteList
    }
    
    func toggleFavourite(id: Int) {
        var favouriteList = self.cachedFavouriteList
        let matchedIndex = favouriteList.firstIndex { $0 == id }
        if let index = matchedIndex {
            favouriteList.remove(at: index)
        } else {
            favouriteList.append(id)
        }
        self.cachedFavouriteList = favouriteList
    }
    
    //MARK: - Private helpers
    
    /// Determine if the cache list is expired
    ///
    /// For simplicity, just check the first item's timestamp
    ///
    private func isCacheExpired(_ cacheList: [MovieItem]) -> Bool {
        if let first = cacheList.first {
            let timeDifference = Date().timeIntervalSince1970 - first.fetchTimestamp
            return timeDifference > DataSourceImp.cacheExpiryThreshhold
        }
        return true // No data, need refresh
    }
    
    /// Any new item to be added to cachedMovieList, repreated items are ignored
    func mergeCache(with newList: [MovieItem]) {
        var cachedList = cachedMovieList
        let nonMatchedItemList = newList.filter { newItem in
            !cachedList.contains { cachedItem in
                cachedItem.id == newItem.id
            }
        }
        cachedList.append(contentsOf: nonMatchedItemList)
        self.cachedMovieList = cachedList
    }
    
    func refreshPersistentStore(with list: [MovieItem]) {
        persistentStore?.persist(list: list)
    }
    
}


