//
//  ProfileViewController.swift
//  AsamAbsense
//
//  Created by ruckef on 04/04/2021.
//

import UIKit

class ProfileViewController: LoadableViewController {
    private lazy var viewModel = AsamAbsenseApp.shared.makeProfileModel()
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        viewModel.delegate = self
        collectionView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetchStatistics()
    }
}

extension ProfileViewController: ProfileViewModelDelegate {
    func showLoading(_ isLoading: Bool) {
        showLoading(isLoading, completion: nil)
    }
    
    func showStatistics() {
        collectionView.isHidden = false
        collectionView.reloadData()
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCellsInRow(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath) as! ProfileCell
        let isInformational = indexPath.section == 0 || indexPath.item == 0
        cell.configureWithTitle(viewModel.titleForIndexPath(indexPath), isInformational: isInformational)
        return cell
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns = viewModel.numberOfCellsInRow(0)
        let itemSize = collectionView.frame.width / CGFloat(columns)
        return CGSize(width: itemSize, height: itemSize / 2)
    }
}
