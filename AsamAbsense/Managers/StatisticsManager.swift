//
//  StatisticsManager.swift
//  AsamAbsense
//
//  Created by ruckef on 04/04/2021.
//

import Foundation

protocol StatisticsManagerProtocol {
    func fetchCurrentYearStatistics(completion: @escaping ([StaticticData]) -> Void)
}

class StatisticsManager: StatisticsManagerProtocol {
    private let absenseManager: AbsenseManagerProtocol
    
    init(absenseManager: AbsenseManagerProtocol) {
        self.absenseManager = absenseManager
    }
    
    func fetchCurrentYearStatistics(completion: @escaping ([StaticticData]) -> Void) {
        absenseManager.fetchAbsenseData { [weak self] absenseData in
            guard let self = self else {
                completion([])
                return
            }
            let separatedAbsenseData = absenseData.reduce(into: [AbsenseType: [Absense]]()) {
                var absenseDataOfOneType = $0[$1.type] ?? []
                absenseDataOfOneType.append($1)
                $0[$1.type] = absenseDataOfOneType
            }
            var statisticsData: [StaticticData] = []
            for absenseType in AbsenseType.allCases {
                let absenseDataOfOneType = separatedAbsenseData[absenseType] ?? []
                let totalDays = self.calculateTotalDaysForAbsenseOfType(absenseType)
                let usedDays = self.calculateUsedDaysForAbsenseData(absenseDataOfOneType)
                let remainingDays = self.calculateRemainingDaysForUsedDays(usedDays, totalDays: totalDays)
                let statisticsOfType = StaticticData(absenseType: absenseType,
                                                     total: totalDays,
                                                     used: usedDays,
                                                     remaining: remainingDays)
                statisticsData.append(statisticsOfType)
            }
            completion(statisticsData)
        }
    }
}

private extension StatisticsManager {
    func calculateTotalDaysForAbsenseOfType(_ type: AbsenseType) -> Int {
        switch type {
        case .vacation:
            return Constants.vacationDays
        case .sickLeave:
            return Constants.sickDays
        case .personalDay, .workFromHome:
            return -1
        }
    }
    
    func calculateUsedDaysForAbsenseData(_ absenseData: [Absense]) -> Int {
        return absenseData.reduce(0) {
            $0 + $1.intervals.reduce(0) { $0 + $1.normalizedToCurrentYear.dayCount }
        }
    }
    
    func calculateRemainingDaysForUsedDays(_ usedDays: Int, totalDays: Int) -> Int {
        guard totalDays > 0 else {
            return -1
        }
        return totalDays - usedDays
    }
}

struct StaticticData {
    let absenseType: AbsenseType
    let total: Int
    let used: Int
    let remaining: Int
}
