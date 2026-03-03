//
//  SourcesTableViewCell.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import UIKit

class SourcesTableViewCell: UITableViewCell {
    @IBOutlet weak var sourceTitle: UILabel!
    @IBOutlet weak var sourceDescription: UILabel!
    @IBOutlet weak var sourceLanguage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(source: NewsSource) {
        sourceTitle.text = source.name
        sourceDescription.text = source.description
        sourceLanguage.text = "Language: \(source.language)"
    }
    
}
