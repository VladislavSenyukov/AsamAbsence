//
//  ProfileCell.swift
//  AsamAbsence
//
//  Created by ruckef on 04/06/2021.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    static let identifier = "ProfileCell"
    @IBOutlet private weak var titleLabel: UILabel!
    
    func configureWithTitle(_ title: String, isInformational: Bool) {
        titleLabel.text = title
        if isInformational {
            titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
            titleLabel.textColor = .black
        } else {
            titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
            titleLabel.textColor = .asamGrey
        }
    }
}
