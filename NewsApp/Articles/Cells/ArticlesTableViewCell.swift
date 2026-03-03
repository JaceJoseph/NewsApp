//
//  ArticlesTableViewCell.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import UIKit
import Kingfisher

class ArticlesTableViewCell: UITableViewCell {
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var publishedAt: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var publishedBy: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(article: NewsArticle, category: String = "general") {
        newsTitle.text = article.title
        publishedBy.text = "published by: \(article.author ?? "anonymous")".uppercased()
        publishedAt.text = "published at: \(article.publishedAtFormatted)".uppercased()
        descriptionLabel.text = article.description ?? "No Description Provided"
        let url = URL(string: "https://example.com/image.png")
        newsImage.kf.setImage(with: url, placeholder: UIImage(named: category))
    }
}
