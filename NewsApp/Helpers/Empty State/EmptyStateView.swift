//
//  EmptyStateView.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import UIKit

/// Empty State used as a Table View background when the data is empty
class EmptyStateView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let nib = UINib(nibName: "EmptyStateView", bundle: nil)
        guard let contentView = nib.instantiate(withOwner: self).first as? UIView else { return }
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }

}
