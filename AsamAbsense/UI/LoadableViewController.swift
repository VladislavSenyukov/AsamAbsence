//
//  LoadableViewController.swift
//  AsamAbsense
//
//  Created by ruckef on 04/05/2021.
//

import UIKit

class LoadableViewController: UIViewController {
    private var loadingVC: UIViewController?
    
    func showLoading(_ isLoading: Bool, completion: (() -> Void)? = nil) {
        if isLoading {
            let loadingVC = AsamAbsenseApp.shared.makeLoadingVC()
            loadingVC.modalPresentationStyle = .overFullScreen
            loadingVC.modalTransitionStyle = .crossDissolve
            present(loadingVC, animated: true, completion: completion)
            self.loadingVC = loadingVC
        } else {
            self.loadingVC?.dismiss(animated: true, completion: completion)
            self.loadingVC = nil
        }
    }
}
