//
//  StatisticsManager.swift
//  AsamAbsence
//
//  Created by ruckef on 04/04/2021.
//

import Foundation

protocol StatisticsManagerProtocol {
    func fetchCurrentYearStatistics(completion: @escaping ([StaticticData]) -> Void)
}

class StatisticsManager: StatisticsManagerProtocol {
    private let absenceManager: AbsenceManagerProtocol
    
    init(absenceManager: AbsenceManagerProtocol) {
        self.absenceManager = absenceManager
    }
    
    func fetchCurrentYearStatistics(completion: @escaping ([StaticticData]) -> Void) {
        absenceManager.fetchAbsenceData { [weak self] absenceData in
            guard let self = self else {
                completion([])
                return
            }
            let separatedAbsenceData = absenceData.reduce(into: [AbsenceType: [Absence]]()) {
                var absenceDataOfOneType = $0[$1.type] ?? []
                absenceDataOfOneType.append($1)
                $0[$1.type] = absenceDataOfOneType
            }
            var statisticsData: [StaticticData] = []
            for absenceType in AbsenceType.allCases {
                let absenceDataOfOneType = separatedAbsenceData[absenceType] ?? []
                let totalDays = self.calculateTotalDaysForAbsenceOfType(absenceType)
                let usedDays = self.calculateUsedDaysForAbsenceData(absenceDataOfOneType)
                let remainingDays = self.calculateRemainingDaysForUsedDays(usedDays, totalDays: totalDays)
                let statisticsOfType = StaticticData(absenceType: absenceType,
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
    func calculateTotalDaysForAbsenceOfType(_ type: AbsenceType) -> Int {
        switch type {
        case .vacation:
            return Constants.vacationDays
        case .sickLeave:
            return Constants.sickDays
        case .personalDay, .workFromHome:
            return -1
        }
    }
    
    func calculateUsedDaysForAbsenceData(_ absenceData: [Absence]) -> Int {
        return absenceData.reduce(0) { $0 + $1.dates.count }
    }
    
    func calculateRemainingDaysForUsedDays(_ usedDays: Int, totalDays: Int) -> Int {
        guard totalDays > 0 else {
            return -1
        }
        return totalDays - usedDays
    }
}

struct StaticticData {
    let absenceType: AbsenceType
    let total: Int
    let used: Int
    let remaining: Int
}
