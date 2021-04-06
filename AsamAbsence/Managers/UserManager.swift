//
//  UserManager.swift
//  AsamAbsence
//
//  Created by ruckef on 04/04/2021.
//

import Foundation

protocol UserManagerProtocol {
    func login(username: String,
               password: String,
               completion: @escaping (Result<User, UserError>) -> Void)
    func logout(completion: @escaping () -> Void)
    var currentUser: User? { get }
}

enum UserError: Error {
    case wrongPassword
}

class UserManager: UserManagerProtocol {
    var userStorage: [String: User] = [:]
    
    func login(username: String,
               password: String,
               completion: @escaping (Result<User, UserError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + Constants.commonDelay) {
            // Ignore password in current implementaion
            guard password != "123" else {
                completion(.failure(.wrongPassword))
                return
            }
            let user = self.userStorage[username] ?? User(id: UUID().uuidString, username: username)
            self.userStorage[username] = user
            self.currentUser = user
            completion(.success(user))
        }
    }
    
    func logout(completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + Constants.commonDelay) {
            self.currentUser = nil
            completion()
        }
    }
    
    var currentUser: User?
}
