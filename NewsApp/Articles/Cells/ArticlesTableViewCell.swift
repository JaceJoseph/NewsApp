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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        setupCard()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shadowView.layer.shadowPath = UIBezierPath(
            roundedRect: shadowView.bounds,
            cornerRadius: 12
        ).cgPath
    }

    private func setupCard() {
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        shadowView.layer.cornerRadius = 8
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.12
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowView.layer.shadowRadius = 8
        shadowView.layer.masksToBounds = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(article: NewsArticle, category: String = "general") {
        newsTitle.text = article.title
        publishedBy.text = "published by: \(article.author ?? "anonymous")".uppercased()
        publishedAt.text = "published at: \(article.publishedAtFormatted)".uppercased()
        descriptionLabel.text = article.description ?? "No Description Provided"
        guard let url = URL(string: article.urlToImage ?? "") else {
            newsImage.image = UIImage(named: category)
            return
        }
        newsImage.kf.indicatorType = .activity
        newsImage.kf.setImage(with: url)
    }
}
