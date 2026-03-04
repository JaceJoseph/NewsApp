//
//  ArticlesViewModel.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import Foundation

/// Protocol to trigger UI related functionality in ArticlesViewController
protocol ArticlesViewModelDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didUpdateArticles()
    func didReceiveError(_ message: String)
}

/// ViewModel used in ArticlesViewController
class ArticlesViewModel {
    var category: String?
    var sourceID: String?

    var getCategory: String {
        guard let category = category else {return ""}
        return category
    }
    
    var getSourceID: String {
        guard let sourceID = sourceID else {return ""}
        return sourceID
    }
    
    private let networkService: NetworkServicing
    private(set) var articles: [NewsArticle] = []
    private var currentKeyword: String = ""
        
    // pagination related variables
    private var currentPage = 1 // current page for pagination
    private let pageSize = 20 // a constant to how many items are returned by the api
    private var isLoading = false // a state to track if is calling api
    private var canLoadMore = true // a state to track if there are more pages
    
    weak var delegate: ArticlesViewModelDelegate?
        
    init(networkService: NetworkServicing = NetworkService.shared) {
        self.networkService = networkService
    }
    
    /// a function that invokes fetchArticle based on a keyword being passed and set it to currentKeyword for pagination fetch later
    /// - Parameter keyword: keyword used as a search term for article fetching
    func searchArticles(keyword: String) async {
        currentKeyword = keyword
        await fetchArticles(reset: true)
    }
    
    /// a function to fetch articles and sets it to the model's variable
    /// - Parameter reset: default as false, if true, resets all pagination related variables such as current page, canLoadMore, and removing all articles
    func fetchArticles(reset: Bool = false) async {
        // resets pagination variables
        if reset {
            currentPage = 1
            canLoadMore = true
            articles.removeAll()
        }
        
        // if is loading or if there are no more pages, don't continue function
        guard !isLoading else { return }
        guard canLoadMore else { return }
        // set loading is true and inform controller that it is loading
        isLoading = true
        delegate?.didStartLoading()

        do {
            /// query item used: apiKey, page for current page requested, pageSize to limit item returned, sources chosen prior, and q for keyword searches
            let response: NewsArticlesResponse = try await networkService.get(
                endpoint: "https://newsapi.org/v2/top-headlines",
                queryItems: [
                    URLQueryItem(name: "q", value: currentKeyword),
                    URLQueryItem(name: "sources", value: getSourceID),
                    URLQueryItem(name: "apiKey", value: NetworkHelper().getAPIToken),
                    URLQueryItem(name: "page", value: "\(currentPage)"),
                    URLQueryItem(name: "pageSize", value: "\(pageSize)")
                ]
            )
            
            let newArticles = response.articles
            // if the count of articles are less than page size (i.e. 10 returned for 20 pageSize, there are no more pages
            print("⬅️ total articles: \(response.totalResults), with page: \(currentPage), currently getting: \(newArticles.count) articles")
            
            if newArticles.count < pageSize {
                canLoadMore = false
            }
            // append articles, increase page, and update UI of the successful update
            articles.append(contentsOf: newArticles)
            currentPage += 1
            delegate?.didUpdateArticles()
            
            // delegates for errors catched to be handled by the UI
        } catch NetworkError.noInternet{
            delegate?.didReceiveError("Sorry, no internet access detected")
        } catch NetworkError.timeout{
            delegate?.didReceiveError("Sorry, getting the articles took way too long")
        } catch let NetworkError.invalidResponse(code){
            delegate?.didReceiveError("Error \(code): Sorry, failed to load the articles")
        } catch let NetworkError.decodingError(error){
            delegate?.didReceiveError("\(error.localizedDescription): Sorry, failed to load articles")
        } catch {
            delegate?.didReceiveError("Sorry, failed to load sources.")
        }
        // remove loading state and inform controller that the fetch is finished and should stop loading
        isLoading = false
        delegate?.didFinishLoading()
    }
    
}
