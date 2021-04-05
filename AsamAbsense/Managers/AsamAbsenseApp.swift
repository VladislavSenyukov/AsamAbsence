//
//  AsamAbsenseApp.swift
//  AsamAbsense
//
//  Created by ruckef on 04/04/2021.
//

import UIKit

class AsamAbsenseApp {
    static let shared = AsamAbsenseApp()
    
    lazy var userManager: UserManagerProtocol = UserManager()
    lazy var absenseManager: AbsenseManagerProtocol = AbsenseManager(userManager: userManager)
    lazy var statisticsManager: StatisticsManagerProtocol = StatisticsManager(absenseManager: absenseManager)
    lazy var storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func makeLoginModel() -> LoginViewModel {
        return LoginViewModel(userManager: userManager)
    }
    
    func makeCalendarModel() -> CalendarViewModel {
        return CalendarViewModel(absenceManager: absenseManager)
    }
    
    func makeLoadingVC() -> UIViewController {
        return storyboard.instantiateViewController(withIdentifier: "LoadingViewController")
    }
    
    func makeMenuVC() -> MenuViewController? {
        return storyboard.instantiateViewController(identifier: "MenuViewController") as? MenuViewController
    }
    
    func makeCalendarVC() -> CalendarViewController? {
        return storyboard.instantiateViewController(identifier: "CalendarViewController") as? CalendarViewController
    }
    
    func makeProfileVC() -> ProfileViewController? {
        return storyboard.instantiateViewController(identifier: "ProfileViewController") as? ProfileViewController
    }
}
