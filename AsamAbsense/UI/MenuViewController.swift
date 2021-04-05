//
//  MenuViewController.swift
//  AsamAbsense
//
//  Created by ruckef on 04/04/2021.
//

import UIKit

class MenuViewController: LoadableViewController {
    private enum MenuOption: String, CaseIterable {
        case calendar
        case profile
        case logout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Menu"
        navigationController?.navigationBar.barTintColor = .asamGreen
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.barStyle = .black
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOption.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell")!
        cell.textLabel?.textColor = .asamGrey
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        cell.textLabel?.text = MenuOption.allCases[indexPath.row].rawValue.capitalized
        return cell
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuOption = MenuOption.allCases[indexPath.row]
        switch menuOption {
        case .calendar:
            guard let calendarVC = AsamAbsenseApp.shared.makeCalendarVC() else {
                return
            }
            navigationController?.pushViewController(calendarVC, animated: true)
        case .profile:
            guard let profileVC = AsamAbsenseApp.shared.makeProfileVC() else {
                return
            }
            navigationController?.pushViewController(profileVC, animated: true)
        case.logout:
            showLoading(true)
            AsamAbsenseApp.shared.userManager.logout { [weak self] in
                DispatchQueue.main.async {
                    self?.showLoading(false) {
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
