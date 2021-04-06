//
//  AbsenceManager.swift
//  AsamAbsence
//
//  Created by ruckef on 04/04/2021.
//

import Foundation

protocol AbsenceManagerProtocol {
    func fetchAbsenceData(completion: @escaping ([Absence]) -> Void)
    func createAbsence(of type: AbsenceType,
                       dates: [CalendarDate],
                       comment: String?,
                       attachments: Set<URL>,
                       completion: @escaping (Absence) -> Void)
    func updateAbsence(_ absence: Absence, completion: @escaping () -> Void)
    func removeAbsence(_ absence: Absence, completion: @escaping () -> Void)
}

class AbsenceManager: AbsenceManagerProtocol {
    private let userManager: UserManagerProtocol
    private var absenceStorage: [String: [String: Absence]] = [:]
    
    init(userManager: UserManagerProtocol) {
        self.userManager = userManager
    }
    
    func fetchAbsenceData(completion: @escaping ([Absence]) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + Constants.commonDelay) {
            guard let userId = self.userManager.currentUser?.id else {
                assertionFailure("User logged out!")
                completion([])
                return
            }
            let absenceData = self.absenceStorage[userId] ?? [:]
            completion(Array(absenceData.values))
        }
    }
    
    func createAbsence(of type: AbsenceType,
                       dates: [CalendarDate],
                       comment: String?,
                       attachments: Set<URL>,
                       completion: @escaping (Absence) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + Constants.commonDelay) {
            let absence = Absence(id: UUID().uuidString,
                                  type: type,
                                  dates: dates,
                                  comment: comment,
                                  attachments: attachments)
            guard let userId = self.userManager.currentUser?.id else {
                assertionFailure("User logged out!")
                completion(absence)
                return
            }
            var absenceData = self.absenceStorage[userId] ?? [:]
            absenceData[absence.id] = absence
            self.absenceStorage[userId] = absenceData
            completion(absence)
        }
    }
    
    func updateAbsence(_ absence: Absence,
                       completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + Constants.commonDelay) {
            guard let userId = self.userManager.currentUser?.id else {
                assertionFailure("User logged out!")
                completion()
                return
            }
            var absenceData = self.absenceStorage[userId] ?? [:]
            absenceData[absence.id] = absence
            self.absenceStorage[userId] = absenceData
            completion()
        }
    }
    
    func removeAbsence(_ absence: Absence, completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + Constants.commonDelay) {
            guard let userId = self.userManager.currentUser?.id else {
                assertionFailure("User logged out!")
                completion()
                return
            }
            var absenceData = self.absenceStorage[userId] ?? [:]
            absenceData[absence.id] = nil
            self.absenceStorage[userId] = absenceData
            completion()
        }
    }
}
