//
//  Helper.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import Foundation
import UIKit

class NetworkHelper {
    var getAPIToken: String {
        
        // setup key
        guard let value = Bundle.main.object(forInfoDictionaryKey: "api_token") as? String else {
            return ""
        }
        return value
    }
}

actor ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    
    func loadImage(from urlString: String) async throws -> UIImage {
        
        if let cached = cache.object(forKey: urlString as NSString) {
            return cached
        }
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        guard let image = UIImage(data: data) else {
            throw NetworkError.invalidResponse
        }
        
        cache.setObject(image, forKey: urlString as NSString)
        return image
    }
}
