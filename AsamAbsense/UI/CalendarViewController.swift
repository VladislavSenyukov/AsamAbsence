//
//  CalendarViewController.swift
//  AsamAbsense
//
//  Created by ruckef on 04/04/2021.
//

import UIKit

class CalendarViewController: LoadableViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var scheduleButton: UIButton!
    @IBOutlet private weak var scheduleButtonTopConstraint: NSLayoutConstraint!
    private lazy var viewModel: CalendarViewModel = AsamAbsenseApp.shared.makeCalendarModel()
    private var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"
        viewModel.delegate = self
        collectionView.isHidden = true
        collectionView.allowsMultipleSelection = true
        scheduleButtonTopConstraint.constant = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !isLoaded else {
            return
        }
        isLoaded = true
        collectionView.scrollToItem(at: viewModel.todayIndexPath, at: .centeredVertically, animated: false)
        viewModel.fetchAbsenseData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scheduleButton.layer.cornerRadius = scheduleButton.frame.height / 2.0
        scheduleButton.layer.masksToBounds = false
        scheduleButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        scheduleButton.layer.shadowColor = UIColor.asamGrey.cgColor
        scheduleButton.layer.shadowOpacity = 0.5
        scheduleButton.layer.shadowRadius = 8
        scheduleButton.titleLabel?.numberOfLines = 1
        scheduleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        scheduleButton.titleLabel?.lineBreakMode = .byClipping
    }
}

private extension CalendarViewController {
    @IBAction func scheduleTapped() {
        guard let scheduleVC = AsamAbsenseApp.shared.makeScheduleVC() else {
            return
        }
        scheduleVC.delegate = self
        scheduleVC.updateScheduleWithDates(viewModel.selectedCalendarDates())
        navigationController?.pushViewController(scheduleVC, animated: true)
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
    
    func showScheduleButton(_ isShown: Bool) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.scheduleButtonTopConstraint.constant = isShown ? 100 : 0
            self.view.layoutIfNeeded()
        }, completion: { _ in} )
    }
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
        let data = viewModel.cellItemDataForIndexPath(indexPath)
        let cellData = CalendarCellViewData(type: data.type,
                                            isSelected: data.isSelected,
                                            dayIndex: indexPath.item,
                                            isToday: indexPath == viewModel.todayIndexPath)
        cell.configureWithData(cellData)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return viewModel.allowsSelectionAtIndexPath(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.toggleSelectionAtIndexPath(indexPath)
        collectionView.reloadItems(at: [indexPath])
    }
}

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout:
                            UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - 6) / 7
        return CGSize(width: itemSize, height: itemSize)
    }
}

extension CalendarViewController: ScheduleViewControllerDelegate {
    func didScheduleAbsense() {
        viewModel.resetSelection()
        showScheduleButton(false)
        collectionView.reloadData()
        isLoaded = false
    }
}
