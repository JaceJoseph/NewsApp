//
//  NewsModels.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import Foundation

/// Model that contains the responses for News Sources
struct NewsSourcesResponse: Codable {
    let status: String
    let sources: [NewsSource]
}

/// Model of a singular News Source
struct NewsSource: Codable {
    let id: String?
    let name: String
    let description: String
    let url: String
    let category: String
    let language: String
    let country: String
}

/// Model that contains the responses for NewsArticle
struct NewsArticlesResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [NewsArticle]
}

/// Model for a singular news article
struct NewsArticle: Codable {
    let source: ArticleSource
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    
    var publishedAtFormatted: String {
        return NetworkHelper().formatISO8601DateString(publishedAt)
    }
}

/// Model for a the source of a  news article
struct ArticleSource: Codable {
    let id: String?
    let name: String
}

/// Model for Article Categories
struct ArticleCategory {
    let id: String
    let title: String
    let description: String
}
