//
//  NetworkManager.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import Foundation
protocol NetworkServicing {
    func get<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem]?
    ) async throws -> T
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
}

final class NetworkService: NetworkServicing {
    static let shared = NetworkService()
    private init() {}
    
    func get<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        
        guard var components = URLComponents(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
// GET https://newsapi.org/v2/top-headlines/sources?q=\(keyword)&category=\(category)&apiKey=\(apiToken)&pageSize=20&page=\(page) (get sources from category)
// GET https://newsapi.org/v2/top-headlines?q=\(keyword)&sources=\(sourceID)&apiKey=\(apiToken)&pageSize=20&page=\(page) (get articles from sources)

// GET https://newsapi.org/v2/top-headlines?q=a&apiKey=1bf317ea5ccd4c918df60076da6cb627&pageSize=20&page=1 (ex for query search)
