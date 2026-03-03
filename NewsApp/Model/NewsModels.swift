//
//  NewsModels.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import Foundation

struct NewsSourcesResponse: Codable {
    let status: String
    let sources: [NewsSource]
}

struct NewsSource: Codable {
    let id: String?
    let name: String
    let description: String
    let url: String
    let category: String
    let language: String
    let country: String
}

struct NewsArticlesResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [NewsArticle]
}

struct NewsArticle: Codable {
    let source: ArticleSource
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: Date?
    let content: String?
    
    var publishedAtFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: publishedAt ?? Date())
    }
}

struct ArticleSource: Codable {
    let id: String?
    let name: String
}

struct ArticleCategory {
    let id: String
    let title: String
    let description: String
}
