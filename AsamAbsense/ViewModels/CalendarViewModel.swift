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
    func showScheduleButton(_ isShown: Bool)
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
        calendarDataItemCache = [:]
        delegate?.showLoading(true)
        absenceManager.fetchAbsenseData { [weak self] absenceData in
            DispatchQueue.main.async {
                self?.delegate?.showLoading(false)
                self?.delegate?.showFetchedAbsenceData(absenceData)
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
            dataItem = CalendarCellItemData(type: .date(cellItemDate), isSelected: false)
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
            guard caledarDate.date.isWeekday else {
                return false
            }
            return !absenceManager.hasAbsenseAtDate(caledarDate.date)
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
        selectedIndexPaths = .init()
        calendarDataItemCache.forEach {
            if $0.value.isSelected {
                var itemData = $0.value
                itemData.isSelected = false
                calendarDataItemCache[$0.key] = itemData
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
