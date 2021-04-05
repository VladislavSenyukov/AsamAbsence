//
//  CalendarViewModel.swift
//  AsamAbsense
//
//  Created by ruckef on 04/04/2021.
//

import Foundation

protocol CalendarViewModelDelegate: AnyObject {
    func showLoading(_ isLoading: Bool)
    func showFetchedAbsenceData(_ absenceData: [Absense])
}

struct CalendarMonthData {
    let month: Int
    let year: Int
    let days: Int
    
    var date: Date {
        let components = DateComponents(year: year, month: month, day: days)
        return Calendar.current.date(from: components)!
    }
}

class CalendarViewModel {
    weak var delegate: CalendarViewModelDelegate?
    private let absenceManager: AbsenseManagerProtocol
    private var daysLayoutPrefixSum: [Int] = []
    private var daysInTwoYears: Int {
        let startOfYear = Date().startOfYear
        let currentYearDays = startOfYear.daysInYear
        let nextYearDays = startOfYear.nextYear.daysInYear
        return currentYearDays + nextYearDays
    }
    private var additionalDays: Int {
        return (7 + (Date().startOfYear.weekdayIndex - 2)) % 7
    }
    private lazy var daysDatasource: [CalendarMonthData] = {
        var daysDatasource: [CalendarMonthData] = []
        let previousYearData = CalendarMonthData(month: 0, year: 0, days: additionalDays)
        daysDatasource.append(previousYearData)
        let now = Date()
        daysDatasource.append(contentsOf: now.startOfYear.monthDataLayout)
        daysDatasource.append(contentsOf: now.nextYear.monthDataLayout)
        return daysDatasource
    }()
    lazy var todayIndexPath: IndexPath = {
        let daysFromStartOfYear = additionalDays + Date().dayIndex - 1
        let section = daysFromStartOfYear / 7
        let item = daysFromStartOfYear % 7
        return IndexPath(item: item, section: section)
    }()
    var numberOfRows: Int {
        return Int(ceil(Double(daysInTwoYears + additionalDays) / 7.0))
    }
    
    init(absenceManager: AbsenseManagerProtocol) {
        self.absenceManager = absenceManager
        let daysLayout = daysDatasource.map { $0.days }
        daysLayoutPrefixSum = prefixSum(daysLayout)
    }
    
    func fetchAbsenseData() {
        delegate?.showLoading(true)
        absenceManager.fetchAbsenseData { [weak self] absenceData in
            DispatchQueue.main.async {
                self?.delegate?.showLoading(false)
                self?.delegate?.showFetchedAbsenceData(absenceData)
            }
        }
    }
    
    func dataForIndexPath(_ indexPath: IndexPath) -> CalendarMonthData? {
        let dayIndex = (indexPath.section * 7) + indexPath.item + 1
        let additionalDays = daysDatasource[0].days
        guard dayIndex > additionalDays else {
            return nil
        }
        guard let monthIndex = daysLayoutPrefixSum.firstIndex(where: { $0 >= dayIndex }) else {
            return nil
        }
        let previousMonthDaySum = daysLayoutPrefixSum[monthIndex-1]
        let dayDiff = dayIndex - previousMonthDaySum
        let day = dayDiff > 0 ? dayDiff : daysDatasource[monthIndex-1].days
        let monthData = daysDatasource[monthIndex]
        return CalendarMonthData(month: monthData.month, year: monthData.year, days: day)
    }
}

private extension CalendarViewModel {
    func prefixSum(_ array: [Int]) -> [Int] {
        array.enumerated().reduce(into: [Int]()) {
            $0.append($1.element + ($1.offset > 0 ? $0[$1.offset - 1] : 0))
        }
    }
}
