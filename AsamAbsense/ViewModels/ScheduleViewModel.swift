//
//  ScheduleViewModel.swift
//  AsamAbsense
//
//  Created by ruckef on 04/05/2021.
//

import Foundation

protocol ScheduleViewModelDelegate: AnyObject {
    func showLoading(_ isLoading: Bool)
    func showScheduledSuccessfully()
}

class ScheduleViewModel {
    weak var delegate: ScheduleViewModelDelegate?
    private var scheduleData = ScheduleData()
    private let absenceManager: AbsenseManagerProtocol
    
    var datesString: String {
        return scheduleData.dates
            .map { $0.date }
            .sorted(by: <)
            .map { formatter.string(from: $0) }
            .joined(separator: ", ")
    }
    
    var absenseTitle: String {
        return scheduleData.type.title
    }
    
    init(absenceManager: AbsenseManagerProtocol) {
        self.absenceManager = absenceManager
    }
    
    func updateDates(_ dates: [CalendarDate]) {
        scheduleData = ScheduleData(dates: dates)
    }
    
    func updateAbsenseType(_ type: AbsenseType) {
        scheduleData.type = type
    }
    
    func scheduleAbsense() {
        delegate?.showLoading(true)
        absenceManager.createAbsense(of: scheduleData.type,
                                     dates: scheduleData.dates,
                                     comment: scheduleData.comment,
                                     attachments: scheduleData.attachments) { _ in
            DispatchQueue.main.async {
                self.delegate?.showLoading(false)
                self.delegate?.showScheduledSuccessfully()
            }
        }
    }
}

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yy"
    return formatter
}()
