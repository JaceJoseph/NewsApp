//
//  NetworkManager.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import Foundation
/// protocol for network servicing, made so to be able to unit test
protocol NetworkServicing {
    func get<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem]?
    ) async throws -> T
}

/// error enum being called back by network services
enum NetworkError: Error {
    case invalidURL
    case invalidResponse(code: Int)
    case decodingError(error: Error)
    case noInternet
    case timeout
}

/// network services used to connect with the API
final class NetworkService: NetworkServicing {
    static let shared = NetworkService()
    private init() {}
    /// A get method used to perform a GET api calls and process the data from the api
    /// - Parameters:
    ///   - endpoint: URL endpoint of the api call
    ///   - queryItems: query strings that is going to be appened in the endpoint when needed. Can be empty and it will not add any query strings beyond the endpoint
    /// - Returns: returns decodable object we created and assign to the call
    func get<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        // check if URL is valid
        guard var components = URLComponents(string: endpoint) else {
            print("❌ Invalid endpoint string: \(endpoint)")
            throw NetworkError.invalidURL
        }
        // assign query items and check if it's valid
        components.queryItems = queryItems
        guard let url = components.url else {
            print("❌ Failed to construct URL from components: \(components.string ?? "")")
            throw NetworkError.invalidURL
        }

        print("➡️ GET Request: \(url.absoluteString)")

        let data: Data
        let response: URLResponse
        // try calling the API, result being a tuple of data and URLResponse
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch let urlError as URLError {
            // catch if URLSession fails
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
            // catch if URLSession fails without any URLError
            print("❌ Unexpected network error: \(error.localizedDescription)")
            throw error
        }
        // continues from successful URLSession, getting Response
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Response is not HTTPURLResponse")
            throw NetworkError.invalidResponse(code: 0)
        }

        print("⬅️ Response status code: \(httpResponse.statusCode)")

        // check if status code is 200 range to see if it succeeded, other than that is a fail and returns error code
        guard 200...299 ~= httpResponse.statusCode else {
            print("❌ Invalid status code: \(httpResponse.statusCode)")
            throw NetworkError.invalidResponse(code: httpResponse.statusCode)
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Response body: \(jsonString)")
        }

        let decoder = JSONDecoder()
        // try decoding the data into the assigned decodable model
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
