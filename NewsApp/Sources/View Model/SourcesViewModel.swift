//
//  SourcesViewModel.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

protocol NewsSourcesViewModelDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didUpdateSources()
    func didReceiveError(_ message: String)
}

import Foundation
class SourcesViewModel {
    var categoryID: String?
    var getCategoryID: String {
        guard let categoryID = categoryID else {return ""}
        return categoryID
    }
    private var allSources: [NewsSource] = []
    private(set) var filteredSources: [NewsSource] = []
    
    weak var delegate: NewsSourcesViewModelDelegate?
    private let networkService: NetworkServicing
    init(networkService: NetworkServicing = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchSources() async {
        delegate?.didStartLoading()
        do {
            let response: NewsSourcesResponse = try await networkService.get(
                endpoint: "https://newsapi.org/v2/top-headlines/sources",
                queryItems: [
                    URLQueryItem(name: "apiKey", value: NetworkHelper().getAPIToken),
                    URLQueryItem(name: "category", value: getCategoryID)
                ]
            )
            allSources = response.sources
            filteredSources = response.sources
            delegate?.didUpdateSources()
            
        } catch NetworkError.noInternet{
            delegate?.didReceiveError("Sorry, no internet access detected")
        } catch NetworkError.timeout{
            delegate?.didReceiveError("Sorry, getting the sources took way too long")
        } catch let NetworkError.invalidResponse(code){
            delegate?.didReceiveError("Error \(code): Sorry, failed to load the sources")
        } catch let NetworkError.decodingError(error){
            delegate?.didReceiveError("\(error.localizedDescription): Sorry, failed to load sources")
        } catch {
            delegate?.didReceiveError("Sorry, failed to load sources.")
        }
        delegate?.didFinishLoading()
        
    }
    
    func searchSources(with query: String?) {
        guard let query = query, !query.isEmpty else {
            filteredSources = allSources
            delegate?.didUpdateSources()
            return
        }
        let lowercasedQuery = query.lowercased()
        filteredSources = allSources.filter {
            $0.name.lowercased().contains(lowercasedQuery)
        }
        delegate?.didUpdateSources()
    }
}
