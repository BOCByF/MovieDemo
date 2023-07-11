//
//  DataSourceAccess.swift
//  MovieDemo
//
//  Created by Shelton Han on 5/7/2023.
//

import Foundation
import CoreData
import OSLog

typealias MovieListCompletion = ([MovieItem], String?) -> Void

class CoreDataAccess {
    let managedContext: NSManagedObjectContext?
    
    init(managedContext: NSManagedObjectContext?) {
        self.managedContext = managedContext
    }
    
    #if DEBUG
    func clearCoreData() {
        let deleteMovieRequest = NSBatchDeleteRequest(fetchRequest: MovieDataItem.fetchRequest())
        let deleteFavouriteRequest = NSBatchDeleteRequest(fetchRequest: FavouriteDataItem.fetchRequest())
        let deleteSettingsRequest = NSBatchDeleteRequest(fetchRequest: SettingsDataItem.fetchRequest())

        do {
            if let managedContext = managedContext {
                try managedContext.persistentStoreCoordinator?.execute(deleteMovieRequest, with: managedContext)
                try managedContext.persistentStoreCoordinator?.execute(deleteFavouriteRequest, with: managedContext)
                try managedContext.persistentStoreCoordinator?.execute(deleteSettingsRequest, with: managedContext)
            }
        } catch {
            Logger().debug("Unable to clear core data")
        }
    }
    #endif
    
    func fetchMovieList() -> [MovieItem] {
        var movieList = [MovieItem]()
        guard let context = managedContext else { return movieList }
        do {
            let movieDataList = try context.fetch(MovieDataItem.fetchRequest())
            let list = movieDataList.map { item in
                MovieItem(id: Int(item.id),
                          title: item.title ?? "",
                          fetchTimestamp: item.fetchTimestamp,
                          releaseDate: item.releaseDate ?? "",
                          posterUrlString: item.posterUrlString ?? "",
                          voteAverage: item.voteAverage,
                          voteCount: Int(item.voteCount),
                          overview: item.overview ?? "")
            }
            movieList.append(contentsOf: list)
        }
        catch {
            Logger().debug("\(error.localizedDescription)")
        }
        return movieList
    }
    
    func fetchFavouriteList() -> [Int] {
        var favouriteList = [Int]()
        guard let context = managedContext else { return favouriteList }
        do {
            let favouriteDataList = try context.fetch(FavouriteDataItem.fetchRequest())
            let list = favouriteDataList.map { Int($0.id) }
            favouriteList.append(contentsOf: list)
        }
        catch {
            Logger().debug("\(error.localizedDescription)")
        }
        return favouriteList
    }
    
    func fetchSettingsOffline() -> Bool {
        var isOffline = false
        guard let context = managedContext else { return isOffline }
        do {
            if let settingsItem = try context.fetch(SettingsDataItem.fetchRequest()).first {
                isOffline = settingsItem.isOfflineMode
            }
        }
        catch {
            Logger().debug("\(error.localizedDescription)")
        }
        return isOffline
    }

    // crash point to fix
    func save(movieItemList: [MovieItem]) {
        guard let context = managedContext else { return }
        
        let existingList = try? context.fetch(MovieDataItem.fetchRequest())
        // Update existing or Add new
        movieItemList.forEach { item in
            let movieDataItem = existingList?.first { $0.id == item.id } ?? MovieDataItem(context: context)
            movieDataItem.id = Int64(item.id)
            movieDataItem.title = item.title
            movieDataItem.fetchTimestamp = item.fetchTimestamp
            movieDataItem.releaseDate = item.releaseDate
            movieDataItem.posterUrlString = item.posterUrlString
            movieDataItem.voteAverage = item.voteAverage
            movieDataItem.voteCount = Int64(item.voteCount)
            movieDataItem.overview = item.overview
        }
        do {
            try context.save()
        }
        catch {
            Logger().debug("\(error.localizedDescription)")
        }
    }
    
    func save(favouriteList: [Int]) {
        guard let context = managedContext else { return }
        
        // Remove all
        let existingList = try? context.fetch(FavouriteDataItem.fetchRequest())
        existingList?.forEach { context.delete($0) }
        
        // Save new
        let favouriteSet = Set(favouriteList)
        favouriteSet.forEach { id in
            let dataItem = FavouriteDataItem(context: context)
            dataItem.id = Int64(id)
        }
        do {
            try context.save()
        }
        catch {
            Logger().debug("\(error.localizedDescription)")
        }
    }
    
    func save(isOfflineMode: Bool) {
        guard let context = managedContext else { return }
        
        // Remove all
        let existingList = try? context.fetch(SettingsDataItem.fetchRequest())
        existingList?.forEach { context.delete($0) }
        
        // Save new
        let dataItem = SettingsDataItem(context: context)
        dataItem.isOfflineMode = isOfflineMode
        do {
            try context.save()
        }
        catch {
            Logger().debug("\(error.localizedDescription)")
        }
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
        } else {
            completion(movieList, nil)
        }
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
    static let cachePagingThreshhold: Int = 16
    
    var persistentStore: CoreDataAccess? = nil
    var networkSource: NetworkAccess? = nil
    
    // Complete dataSource cache
    var cachedMovieList = [MovieItem]()
    var cachedFavouriteList = [Int]()
    
    /// Depending on the restore point, preload data
    init(restore: CoreDataAccess?, network: NetworkAccess?) {
        persistentStore = restore
        if let movieList = restore?.fetchMovieList() {
            cachedMovieList = movieList
        }
        if let favouriteList = restore?.fetchFavouriteList() {
            cachedFavouriteList = favouriteList
        }
        networkSource = network
    }
    
    // Mark: - MovieList
    
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
        if isCacheExpired(cachedList, page: page), let networkSource = networkSource {
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
    
    // MARK: - Favourites
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
        persistentStore?.save(favouriteList: favouriteList)
    }
    
    // MARK: - Settings
    func fetchSettingsOfflineMode() -> Bool {
        let isOffline = persistentStore?.fetchSettingsOffline() ?? false
        return isOffline
    }
    
    func toggleRemoteAccess(with remote: NetworkAccess?) {
        self.networkSource = remote
        let isOffline = remote == nil ? true : false
        self.persistentStore?.save(isOfflineMode: isOffline)
    }
    
    //MARK: - Private helpers
    
    /// Determine if the cache list is expired
    ///
    /// For simplicity, just check the first item's timestamp
    ///
    private func isCacheExpired(_ cacheList: [MovieItem], page: Int) -> Bool {
        let skipCount = max(0, DataSourceImp.cachePagingThreshhold * (page - 1))
        let cacheList = cacheList.dropFirst(skipCount)
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
        persistentStore?.save(movieItemList: list)
    }
    
}


