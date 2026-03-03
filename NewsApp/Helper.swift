//
//  Helper.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import Foundation
class NetworkHelper {
    var getAPIToken: String {
        
        // setup key
        guard let value = Bundle.main.object(forInfoDictionaryKey: "api_token") as? String else {
            return ""
        }
        return value
    }
    
    let newsCategory: [String] = ["technology", "general", "business", "sports", "entertainment", "science"]
}
