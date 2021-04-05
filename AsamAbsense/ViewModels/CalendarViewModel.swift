//
//  CalendarViewModel.swift
//  AsamAbsense
//
//  Created by ruckef on 04/04/2021.
//

import Foundation

protocol CalendarViewModelDelegate: AnyObject {
    func showLoading(_ isLoading: Bool)
    func showFetchedAbsenceData()
    func showScheduleButton(_ isShown: Bool)
    func reload()
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
    private lazy var calendarDataItemCache: [IndexPath: CalendarCellItemData] = [:]
    private lazy var selectedIndexPaths = Set<IndexPath>()
    private var absenseMap: [CalendarDate: Absense] = [:]
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
        absenceManager.fetchAbsenseData { [weak self] absenseData in
            self?.absenseMap = absenseData.reduce([:]) { (result, absense) in
                let next = absense.dates
                    .reduce(into: [CalendarDate: Absense]()) { $0[$1] = absense }
                return result.merging(next,
                                      uniquingKeysWith: { (_, new) in new })
            }
            self?.calendarDataItemCache = [:]
            DispatchQueue.main.async {
                self?.delegate?.showLoading(false)
                self?.delegate?.showFetchedAbsenceData()
            }
        }
    }
    
    func cellItemDataForIndexPath(_ indexPath: IndexPath) -> CalendarCellItemData {
        if let cached = calendarDataItemCache[indexPath] {
            return cached
        }
        let dayIndex = (indexPath.section * 7) + indexPath.item + 1
        let additionalDays = daysDatasource[0].days
        let dataItem: CalendarCellItemData
        if dayIndex > additionalDays, let monthIndex = daysLayoutPrefixSum.firstIndex(where: { $0 >= dayIndex }) {
            let previousMonthDaySum = daysLayoutPrefixSum[monthIndex-1]
            let dayDiff = dayIndex - previousMonthDaySum
            let day = dayDiff > 0 ? dayDiff : daysDatasource[monthIndex-1].days
            let monthData = daysDatasource[monthIndex]
            let cellItemDate = CalendarDate(year: monthData.year,
                                            month: monthData.month,
                                            day: day)
            dataItem = CalendarCellItemData(type: .date(cellItemDate),
                                            isSelected: false,
                                            absenseType: absenseMap[cellItemDate]?.type)
        } else {
            dataItem = CalendarCellItemData(type: .empty, isSelected: false)
        }
        calendarDataItemCache[indexPath] = dataItem
        return dataItem
    }
    
    func allowsSelectionAtIndexPath(_ indexPath: IndexPath) -> Bool {
        let cellData = cellItemDataForIndexPath(indexPath)
        switch cellData.type {
        case .empty:
            return false
        case .date(let caledarDate):
            return
                caledarDate.date.isWeekday &&
                caledarDate.date.startOfDay >= Date().startOfDay
        }
    }
    
    func absenseDataForIndexPath(_ indexPath: IndexPath) -> Absense? {
        let cellData = cellItemDataForIndexPath(indexPath)
        switch cellData.type {
        case .empty:
            return nil
        case .date(let caledarDate):
            return absenseMap[caledarDate]
        }
    }
    
    func toggleSelectionAtIndexPath(_ indexPath: IndexPath) {
        var cellData = cellItemDataForIndexPath(indexPath)
        cellData.isSelected.toggle()
        let isEmpty = selectedIndexPaths.isEmpty
        if cellData.isSelected {
            selectedIndexPaths.insert(indexPath)
        } else {
            selectedIndexPaths.remove(indexPath)
        }
        calendarDataItemCache[indexPath] = cellData
        if selectedIndexPaths.isEmpty != isEmpty {
            delegate?.showScheduleButton(!selectedIndexPaths.isEmpty)
        }
    }
    
    func selectedCalendarDates() -> [CalendarDate] {
        return selectedIndexPaths.compactMap {
            switch cellItemDataForIndexPath($0).type {
            case .date(let date):
                return date
            case .empty:
                return nil
            }
        }
    }
    
    func resetSelection() {
        selectedIndexPaths.removeAll()
        calendarDataItemCache.removeAll()
    }
    
    func removeDayWithIndexPath(_ indexPath: IndexPath, from absense: Absense) {
        let cellData = cellItemDataForIndexPath(indexPath)
        guard
            case .date(let date) = cellData.type,
            let dateIndex = absense.dates.firstIndex(of: date) else {
            return
        }
        var absense = absense
        absense.dates.remove(at: dateIndex)
        delegate?.showLoading(true)
        absenceManager.updateAbsense(absense) { [weak self] in
            DispatchQueue.main.async {
                self?.delegate?.showLoading(false)
                self?.delegate?.reload()
            }
        }
    }
}

private extension CalendarViewModel {
    func prefixSum(_ array: [Int]) -> [Int] {
        array.enumerated().reduce(into: [Int]()) {
            $0.append($1.element + ($1.offset > 0 ? $0[$1.offset - 1] : 0))
        }
    }
}
