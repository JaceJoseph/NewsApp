//
//  ArticlesViewModel.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import Foundation

protocol ArticlesViewModelDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didUpdateArticles()
    func didReceiveError(_ message: String)
}

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
        
    private var currentPage = 1
    private let pageSize = 20
    private var isLoading = false
    private var canLoadMore = true
    weak var delegate: ArticlesViewModelDelegate?
        
    init(networkService: NetworkServicing = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func searchArticles(keyword: String) {
        currentKeyword = keyword
        fetchArticles(reset: true)
    }
    
    func fetchArticles(reset: Bool = false) {
        if reset {
            currentPage = 1
            canLoadMore = true
            articles.removeAll()
        }
        
        guard !isLoading else { return }
        guard canLoadMore else { return }
        
        isLoading = true
        delegate?.didStartLoading()

        Task {
            do {
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
                
                if newArticles.count < pageSize {
                    canLoadMore = false
                }
                
                articles.append(contentsOf: newArticles)
                currentPage += 1
                
                delegate?.didUpdateArticles()
                
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
            
            isLoading = false
            delegate?.didFinishLoading()
        }
    }
}
