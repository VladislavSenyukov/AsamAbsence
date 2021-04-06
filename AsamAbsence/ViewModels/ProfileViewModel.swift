//
//  ProfileViewModel.swift
//  AsamAbsence
//
//  Created by ruckef on 04/04/2021.
//

import Foundation

protocol ProfileViewModelDelegate: AnyObject {
    func showLoading(_ isLoading: Bool)
    func showStatistics()
}

class ProfileViewModel {
    weak var delegate: ProfileViewModelDelegate?
    private let statisticsManager: StatisticsManagerProtocol
    private var dataStrings: [[String]] = []
    
    var numberOfRows: Int {
        return dataStrings.count
    }
    
    init(statisticsManager: StatisticsManagerProtocol) {
        self.statisticsManager = statisticsManager
    }
    
    func fetchStatistics() {
        delegate?.showLoading(true)
        statisticsManager.fetchCurrentYearStatistics { [weak self] statisticsData in
            var dataStrings: [[String]] = []
            let titlesRow = ["Absence Type", "Total", "Used", "Remaining"]
            dataStrings.append(titlesRow)
            for statistics in statisticsData {
                var statisticsRow: [String] = []
                statisticsRow.append(statistics.absenceType.title)
                let total = statistics.total
                let used = statistics.used
                let remaning = statistics.remaining
                statisticsRow.append(total >= 0 ? total.description : "-")
                statisticsRow.append(used >= 0 ? used.description : "-")
                statisticsRow.append(remaning >= 0 ? remaning.description : "-")
                dataStrings.append(statisticsRow)
            }
            self?.dataStrings = dataStrings
            DispatchQueue.main.async {
                self?.delegate?.showLoading(false)
                self?.delegate?.showStatistics()
            }
        }
    }
    
    func numberOfCellsInRow(_ row: Int) -> Int {
        return dataStrings[row].count
    }
    
    func titleForIndexPath(_ indexPath: IndexPath) -> String {
        return dataStrings[indexPath.section][indexPath.item]
    }
}
