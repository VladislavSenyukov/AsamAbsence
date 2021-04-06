//
//  ScheduleViewModel.swift
//  AsamAbsence
//
//  Created by ruckef on 04/05/2021.
//

import Foundation

protocol ScheduleViewModelDelegate: AnyObject {
    func showLoading(_ isLoading: Bool)
    func showAbsenceCreated()
    func showAbsenceUpdated()
}

class ScheduleViewModel {
    weak var delegate: ScheduleViewModelDelegate?
    private var scheduleData = ScheduleData()
    private let absenceManager: AbsenceManagerProtocol
    private var editingAbsence: Absence?
    
    var datesString: String {
        return scheduleData.dates
            .map { $0.date }
            .sorted(by: <)
            .map { formatter.string(from: $0) }
            .joined(separator: ", ")
    }
    
    var absenceTitle: String {
        return scheduleData.type.title
    }
    
    var comment: String? {
        return scheduleData.comment
    }
    
    var attachmentsString: String {
        let string = scheduleData.attachments.map { $0.lastPathComponent }.joined(separator: ", ")
        return string.isEmpty ? "Select" : string
    }
    
    init(absenceManager: AbsenceManagerProtocol) {
        self.absenceManager = absenceManager
    }
    
    func updateDates(_ dates: [CalendarDate]) {
        scheduleData = ScheduleData(dates: dates)
    }
    
    func updateAbsenceType(_ type: AbsenceType) {
        scheduleData.type = type
    }
    
    func updateComment(_ comment: String?) {
        scheduleData.comment = comment
    }
    
    func addAttachment(_ url: URL) {
        scheduleData.attachments.insert(url)
    }
    
    func updateFromAbsence(_ absence: Absence) {
        scheduleData.type = absence.type
        scheduleData.dates = absence.dates
        scheduleData.comment = absence.comment
        scheduleData.attachments = absence.attachments
        editingAbsence = absence
    }
    
    func scheduleAbsence() {
        delegate?.showLoading(true)
        absenceManager.createAbsence(of: scheduleData.type,
                                     dates: scheduleData.dates,
                                     comment: scheduleData.comment,
                                     attachments: scheduleData.attachments) { [weak self] _ in
            DispatchQueue.main.async {
                self?.delegate?.showLoading(false)
                self?.delegate?.showAbsenceCreated()
            }
        }
    }
    
    func updateAbsence () {
        guard var absence = editingAbsence else {
            return
        }
        absence.type = scheduleData.type
        absence.dates = scheduleData.dates
        absence.comment = scheduleData.comment
        absence.attachments = scheduleData.attachments
        delegate?.showLoading(true)
        absenceManager.updateAbsence(absence) { [weak self] in
            DispatchQueue.main.async {
                self?.delegate?.showLoading(false)
                self?.delegate?.showAbsenceUpdated()
            }
        }
    }
    
    func cancelAbsence() {
        guard let absence = editingAbsence else {
            return
        }
        delegate?.showLoading(true)
        absenceManager.removeAbsence(absence) { [weak self] in
            DispatchQueue.main.async {
                self?.delegate?.showLoading(false)
                self?.delegate?.showAbsenceUpdated()
            }
        }
    }
}

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yy"
    return formatter
}()
