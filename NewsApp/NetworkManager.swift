//
//  NetworkManager.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import Foundation
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
}

final class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "https://newsapi.org/v2/"
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
