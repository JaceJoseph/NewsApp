//
//  CategoryTableCell.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import UIKit

class CategoryTableCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var categoryDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryImage.layer.cornerRadius = 8
        selectionStyle = .none
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
