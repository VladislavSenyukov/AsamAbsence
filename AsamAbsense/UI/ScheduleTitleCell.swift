//
//  ScheduleTitleCell.swift
//  AsamAbsense
//
//  Created by ruckef on 04/05/2021.
//

import UIKit

class ScheduleTitleCell: UITableViewCell {
    static let cellIdentifier = "ScheduleTitleCell"
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .asamGrey
        descriptionLabel.textColor = .lightGray
    }
    
    func configure(_ title: String, text: String) {
        titleLabel.text = title
        descriptionLabel.text = text
    }
}
