//
//  NetworkManager.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import Foundation
/// <#Description#>
protocol NetworkServicing {
    func get<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem]?
    ) async throws -> T
}

/// <#Description#>
enum NetworkError: Error {
    case invalidURL
    case invalidResponse(code: Int)
    case decodingError(error: Error)
    case noInternet
    case timeout
}

/// <#Description#>
final class NetworkService: NetworkServicing {
    static let shared = NetworkService()
    private init() {}
    /// <#Description#>
    /// - Parameters:
    ///   - endpoint: <#endpoint description#>
    ///   - queryItems: <#queryItems description#>
    /// - Returns: <#description#>
    func get<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {

        guard var components = URLComponents(string: endpoint) else {
            print("❌ Invalid endpoint string: \(endpoint)")
            throw NetworkError.invalidURL
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            print("❌ Failed to construct URL from components: \(components.string ?? "")")
            throw NetworkError.invalidURL
        }

        print("➡️ GET Request: \(url.absoluteString)")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch let urlError as URLError {

            print("❌ URLError: \(urlError.localizedDescription)")

            switch urlError.code {
            case .notConnectedToInternet:
                throw NetworkError.noInternet
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw urlError
            }
        } catch {
            print("❌ Unexpected network error: \(error.localizedDescription)")
            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Response is not HTTPURLResponse")
            throw NetworkError.invalidResponse(code: 0)
        }

        print("⬅️ Response status code: \(httpResponse.statusCode)")

        guard 200...299 ~= httpResponse.statusCode else {
            print("❌ Invalid status code: \(httpResponse.statusCode)")
            throw NetworkError.invalidResponse(code: httpResponse.statusCode)
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Response body: \(jsonString)")
        }

        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(T.self, from: data)
            print("✅ Successfully decoded response into \(String(describing: T.self))")
            return decoded
        } catch {
            print("❌ Decoding failed: \(error.localizedDescription)")
            throw NetworkError.decodingError(error: error)
        }
    }
}
