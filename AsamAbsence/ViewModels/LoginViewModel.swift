//
//  LoginViewModel.swift
//  AsamAbsence
//
//  Created by ruckef on 04/04/2021.
//

import Foundation

protocol LoginViewModelDelegate: AnyObject {
    func showLoading(_ isLoading: Bool)
    func showUserLoggedIn()
    func showLoginError(_ error: LoginViewModelError)
}

enum LoginViewModelError: Error {
    case userManagerError(UserError)
    case usernameIsEmpty
    case passwordIsEmpty
    
    var description: String {
        switch self {
        case .userManagerError(let userError):
            switch userError {
            case .wrongPassword:
                return "The password is wrong!"
            }
        case .passwordIsEmpty:
            return "The password field must not be empty!"
        case .usernameIsEmpty:
            return "The user name field must not be empty!"
        }
    }
}

class LoginViewModel {
    weak var delegate: LoginViewModelDelegate?
    private let userManager: UserManagerProtocol
    
    init(userManager: UserManagerProtocol) {
        self.userManager = userManager
    }
    
    func loginUserWithName(_ username: String, password: String) {
        guard !username.isEmpty else {
            delegate?.showLoginError(.usernameIsEmpty)
            return
        }
        guard !password.isEmpty else {
            delegate?.showLoginError(.passwordIsEmpty)
            return
        }
        delegate?.showLoading(true)
        userManager.login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.delegate?.showLoading(false)
                switch result {
                case .success:
                    self?.delegate?.showUserLoggedIn()
                case .failure(let error):
                    self?.delegate?.showLoginError(.userManagerError(error))
                }
            }
        }
    }
}
