//
//  UIAlert+Extensions.swift
//  AsamAbsense
//
//  Created by ruckef on 04/05/2021.
//

import UIKit

extension UIAlertController {
    static func makeOkAlert(title: String?, message: String?) -> UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .default, handler: nil))
        return alert
    }
}
