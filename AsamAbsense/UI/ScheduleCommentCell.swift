//
//  ScheduleCommentCell.swift
//  AsamAbsense
//
//  Created by ruckef on 04/06/2021.
//

import UIKit

class ScheduleCommentCell: UITableViewCell {
    static let identifier = "ScheduleCommentCell"
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var commentField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .asamGrey
        commentField.textColor = .lightGray
    }
    
    func configure(_ title: String, comment: String?) {
        titleLabel.text = title
        commentField.text = comment
    }
}
