//
//  AbsenseManager.swift
//  AsamAbsense
//
//  Created by ruckef on 04/04/2021.
//

import Foundation

protocol AbsenseManagerProtocol {
    func fetchAbsenseData(completion: @escaping ([Absense]) -> Void)
    func createAbsense(of type: AbsenseType,
                       dates: [CalendarDate],
                       comment: String?,
                       attachments: Set<URL>,
                       completion: @escaping (Absense) -> Void)
    func updateAbsense(_ absense: Absense, completion: @escaping () -> Void)
    func removeAbsense(_ absense: Absense, completion: @escaping () -> Void)
}

class AbsenseManager: AbsenseManagerProtocol {
    private let userManager: UserManagerProtocol
    private var absenseStorage: [String: [String: Absense]] = [:]
    
    init(userManager: UserManagerProtocol) {
        self.userManager = userManager
    }
    
    func fetchAbsenseData(completion: @escaping ([Absense]) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + Constants.commonDelay) {
            guard let userId = self.userManager.currentUser?.id else {
                assertionFailure("User logged out!")
                completion([])
                return
            }
            let absenseData = self.absenseStorage[userId] ?? [:]
            completion(Array(absenseData.values))
        }
    }
    
    func createAbsense(of type: AbsenseType,
                       dates: [CalendarDate],
                       comment: String?,
                       attachments: Set<URL>,
                       completion: @escaping (Absense) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + Constants.commonDelay) {
            let absense = Absense(id: UUID().uuidString,
                                  type: type,
                                  dates: dates,
                                  comment: comment,
                                  attachments: attachments)
            guard let userId = self.userManager.currentUser?.id else {
                assertionFailure("User logged out!")
                completion(absense)
                return
            }
            var absenseData = self.absenseStorage[userId] ?? [:]
            absenseData[absense.id] = absense
            self.absenseStorage[userId] = absenseData
            completion(absense)
        }
    }
    
    func updateAbsense(_ absense: Absense,
                       completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + Constants.commonDelay) {
            guard let userId = self.userManager.currentUser?.id else {
                assertionFailure("User logged out!")
                completion()
                return
            }
            var absenseData = self.absenseStorage[userId] ?? [:]
            absenseData[absense.id] = absense
            self.absenseStorage[userId] = absenseData
            completion()
        }
    }
    
    func removeAbsense(_ absense: Absense, completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + Constants.commonDelay) {
            guard let userId = self.userManager.currentUser?.id else {
                assertionFailure("User logged out!")
                completion()
                return
            }
            var absenseData = self.absenseStorage[userId] ?? [:]
            absenseData[absense.id] = nil
            self.absenseStorage[userId] = absenseData
            completion()
        }
    }
}
