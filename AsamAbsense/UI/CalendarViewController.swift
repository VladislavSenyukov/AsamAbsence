//
//  CalendarViewController.swift
//  AsamAbsense
//
//  Created by ruckef on 04/04/2021.
//

import UIKit

class CalendarViewController: LoadableViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    private lazy var viewModel: CalendarViewModel = AsamAbsenseApp.shared.makeCalendarModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"
        viewModel.delegate = self
        collectionView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.scrollToItem(at: viewModel.todayIndexPath, at: .centeredVertically, animated: false)
        viewModel.fetchAbsenseData()
    }
}

extension CalendarViewController: CalendarViewModelDelegate {
    func showLoading(_ isLoading: Bool) {
        showLoading(isLoading, completion: nil)
    }
    
    func showFetchedAbsenceData(_ absenceData: [Absense]) {
        collectionView.isHidden = false
        print("data loaded")
    }
}

extension CalendarViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell
        let data = viewModel.dataForIndexPath(indexPath)
        cell.configureWithData(data,
                               isToday: indexPath == viewModel.todayIndexPath,
                               dayIndex: indexPath.item)
        return cell
    }
}

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout:
                            UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width / 7).rounded(.down)
        return CGSize(width: itemSize, height: itemSize)
    }
}
