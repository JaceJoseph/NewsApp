//
//  CategoryTableCell.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import UIKit

class CategoryTableCell: UITableViewCell {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var categoryDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupCard()
    }
    
    private func setupCard() {
        selectionStyle = .none
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
    
    func configCell(category: ArticleCategory) {
        categoryTitle.text = category.title
        categoryDescription.text = category.description
        categoryImage.image = UIImage(named: category.id)
    }
    
}
