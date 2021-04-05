//
//  LoginViewController.swift
//  AsamAbsense
//
//  Created by ruckef on 04/04/2021.
//

import UIKit

class LoginViewController: LoadableViewController {
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var goButton: UIButton!
    private lazy var viewModel: LoginViewModel = AsamAbsenseApp.shared.makeLoginModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        goButton.backgroundColor = .asamGreen
        loginField.textColor = .asamGrey
        passwordField.textColor = .asamGrey
        let attributedString = NSMutableAttributedString(string: logoLabel.text ?? "")
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: UIColor.asamGrey,
                                      range: NSRange(location: 0, length: 4))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: UIColor.asamGreen,
                                      range: NSRange(location: 4, length: attributedString.length - 4))
        logoLabel.attributedText = attributedString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginField.text = ""
        passwordField.text = ""
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        goButton.layer.cornerRadius = goButton.frame.height / 2.0

    }
    
    @IBAction private func backgroundTapped() {
        loginField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    @IBAction private func goButtonTapped() {
        performLogin()
    }
    
    private func performLogin() {
        viewModel.loginUserWithName(loginField.text ?? "", password: passwordField.text ?? "")
    }
}

extension LoginViewController: LoginViewModelDelegate {
    func showLoading(_ isLoading: Bool) {
        showLoading(isLoading, completion: nil)
    }
    
    func showUserLoggedIn() {
        guard let menuVC = AsamAbsenseApp.shared.makeMenuVC() else {
            return
        }
        let navigationController = UINavigationController(rootViewController: menuVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    func showLoginError(_ error: LoginViewModelError) {
        let alert = UIAlertController.makeOkAlert(title: "Error", message: error.description)
        present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            passwordField.resignFirstResponder()
            performLogin()
        }
        return true
    }
}
