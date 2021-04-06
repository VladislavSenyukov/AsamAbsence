//
//  ScheduleViewModel.swift
//  AsamAbsense
//
//  Created by ruckef on 04/05/2021.
//

import Foundation

protocol ScheduleViewModelDelegate: AnyObject {
    func showLoading(_ isLoading: Bool)
    func showAbsenseCreated()
    func showAbsenseUpdated()
}

class ScheduleViewModel {
    weak var delegate: ScheduleViewModelDelegate?
    private var scheduleData = ScheduleData()
    private let absenceManager: AbsenseManagerProtocol
    private var editingAbsense: Absense?
    
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
    
    var comment: String? {
        return scheduleData.comment
    }
    
    var attachmentsString: String {
        let string = scheduleData.attachments.map { $0.lastPathComponent }.joined(separator: ", ")
        return string.isEmpty ? "Select" : string
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
    
    func updateComment(_ comment: String?) {
        scheduleData.comment = comment
    }
    
    func addAttachment(_ url: URL) {
        scheduleData.attachments.insert(url)
    }
    
    func updateFromAbsense(_ absense: Absense) {
        scheduleData.type = absense.type
        scheduleData.dates = absense.dates
        scheduleData.comment = absense.comment
        scheduleData.attachments = absense.attachments
        editingAbsense = absense
    }
    
    func scheduleAbsense() {
        delegate?.showLoading(true)
        absenceManager.createAbsense(of: scheduleData.type,
                                     dates: scheduleData.dates,
                                     comment: scheduleData.comment,
                                     attachments: scheduleData.attachments) { [weak self] _ in
            DispatchQueue.main.async {
                self?.delegate?.showLoading(false)
                self?.delegate?.showAbsenseCreated()
            }
        }
    }
    
    func updateAbsense () {
        guard var absense = editingAbsense else {
            return
        }
        absense.type = scheduleData.type
        absense.dates = scheduleData.dates
        absense.comment = scheduleData.comment
        absense.attachments = scheduleData.attachments
        delegate?.showLoading(true)
        absenceManager.updateAbsense(absense) { [weak self] in
            DispatchQueue.main.async {
                self?.delegate?.showLoading(false)
                self?.delegate?.showAbsenseUpdated()
            }
        }
    }
    
    func cancelAbsense() {
        guard let absense = editingAbsense else {
            return
        }
        delegate?.showLoading(true)
        absenceManager.removeAbsense(absense) { [weak self] in
            DispatchQueue.main.async {
                self?.delegate?.showLoading(false)
                self?.delegate?.showAbsenseUpdated()
            }
        }
    }
}

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yy"
    return formatter
}()
