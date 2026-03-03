//
//  CategoryViewModel.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import Foundation
class CategoryViewModel {
    let newsCategory: [ArticleCategory] = [
        ArticleCategory(id: "general", title: "GENERAL", description: "For your general catchup for news"),
        ArticleCategory(id: "business", title: "BUSINESS", description: "Catchup to the latest economic and business news"),
        ArticleCategory(id: "technology", title: "TECHNOLOGY", description: "Keep up with the latest technology"),
        ArticleCategory(id: "sports", title: "GENERAL", description: "Find out about your latest favourite sports news"),
        ArticleCategory(id: "entertainment", title: "ENTERTAINMENT", description: "For your latest entertainment purposes"),
        ArticleCategory(id: "science", title: "SCIENCE", description: "Keep up with the latest scientific findings")
    ]
    
    func getCategory(index: Int) -> ArticleCategory {
        return newsCategory[index]
    }
}
