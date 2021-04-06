//
//  AsamAbsenceApp.swift
//  AsamAbsence
//
//  Created by ruckef on 04/04/2021.
//

import UIKit

class AsamAbsenceApp {
    static let shared = AsamAbsenceApp()
    
    lazy var userManager: UserManagerProtocol = UserManager()
    lazy var absenceManager: AbsenceManagerProtocol = AbsenceManager(userManager: userManager)
    lazy var statisticsManager: StatisticsManagerProtocol = StatisticsManager(absenceManager: absenceManager)
    lazy var storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    func makeLoginModel() -> LoginViewModel {
        return LoginViewModel(userManager: userManager)
    }
    
    func makeCalendarModel() -> CalendarViewModel {
        return CalendarViewModel(absenceManager: absenceManager)
    }
    
    func makeScheduleModel() -> ScheduleViewModel {
        return ScheduleViewModel(absenceManager: absenceManager)
    }
    
    func makeProfileModel() -> ProfileViewModel {
        return ProfileViewModel(statisticsManager: statisticsManager)
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
    
    func makeScheduleVC() -> ScheduleViewController? {
        return storyboard.instantiateViewController(identifier: "ScheduleViewController") as? ScheduleViewController
    }
    
    func makeProfileVC() -> ProfileViewController? {
        return storyboard.instantiateViewController(identifier: "ProfileViewController") as? ProfileViewController
    }
}
