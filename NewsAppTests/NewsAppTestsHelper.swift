//
//  NewsAppTests.swift
//  NewsAppTests
//
//  Created by Jesse on 03/03/26.
//

import XCTest
@testable import NewsApp

final class MockNetworkService: NetworkServicing {
    var result: Result<Any, Error>?
    
    func get<T>(endpoint: String, queryItems: [URLQueryItem]?) async throws -> T where T : Decodable {
        switch result {
        case .success(let value):
            return value as! T
        case .failure(let error):
            throw error
        case .none:
            fatalError("Mock result not set")
        }
    }
}


