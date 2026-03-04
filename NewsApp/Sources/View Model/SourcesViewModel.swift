//
//  SourcesViewModel.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

/// Protocol to trigger UI related functionality in SourcesViewController
protocol NewsSourcesViewModelDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didUpdateSources()
    func didReceiveError(_ message: String)
}

import Foundation
/// View Model for SourcesViewController
class SourcesViewModel {
    /// categoryID used as a parameter to get sources based on the category chosen
    var categoryID: String?
    var getCategoryID: String {
        guard let categoryID = categoryID else {return ""}
        return categoryID
    }
    /// sources are separated into all for master, and filtered if user searches for filter purposes
    private var allSources: [NewsSource] = []
    private(set) var filteredSources: [NewsSource] = []
    
    weak var delegate: NewsSourcesViewModelDelegate?
    private let networkService: NetworkServicing
    init(networkService: NetworkServicing = NetworkService.shared) {
        self.networkService = networkService
    }
    
    /// fetches news sources and sets it to allSources and filteredSources (filteredSources is the same here because it's the first fetch without any keyword)
    func fetchSources() async {
        // triggers loading
        delegate?.didStartLoading()
        do {
            /// query item used: apiKey and category chosen prior
            let response: NewsSourcesResponse = try await networkService.get(
                endpoint: "https://newsapi.org/v2/top-headlines/sources",
                queryItems: [
                    URLQueryItem(name: "apiKey", value: NetworkHelper().getAPIToken),
                    URLQueryItem(name: "category", value: getCategoryID)
                ]
            )
            // if success, assigns data and tells the controller update is a success
            allSources = response.sources
            filteredSources = response.sources
            delegate?.didUpdateSources()
           
            // delegates for various errors catched
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
        // stops loading
        delegate?.didFinishLoading()
        
    }
    
    /// Function to filter sources based on the keyword used to query the sources. Will modify fitleredSources, filtered if keyword is not empty, and resets into allSources when keyword is empty or nil
    /// - Parameter query: keywords used to filter the array of allSources into filteredSources. can be empty/nil
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
