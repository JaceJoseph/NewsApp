//
//  CategoryViewModel.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import Foundation
class CategoryViewModel {
    let newsCategory: [ArticleCategory] = [
        ArticleCategory(id: "general", title: "GENERAL", description: "The general news, ready to be perused by you, giving you the latest trending news available for you"),
        ArticleCategory(id: "business", title: "BUSINESS", description: "Get the latest business updates and economic related information with the latest business related news"),
        ArticleCategory(id: "technology", title: "TECHNOLOGY", description: "Keep up with the latest technology trends by visiting the latest available news in technology"),
        ArticleCategory(id: "sports", title: "SPORTS", description: "Find more out about your latest favourite sports related news in the sports section"),
        ArticleCategory(id: "entertainment", title: "ENTERTAINMENT", description: "Find more entertainment for your leisure and fun with the latest entertainment news"),
        ArticleCategory(id: "health", title: "HEALTH", description: "Keep healthy by keeping up to date with the latest health related news available"),
        ArticleCategory(id: "science", title: "SCIENCE", description: "Explore more and deepen your knowledge with the breakthrough in science, available for you to browse in the latest science related news")
    ]
    
    func getCategory(index: Int) -> ArticleCategory {
        return newsCategory[index]
    }
}
