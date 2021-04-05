//
//  Absense.swift
//  AsamAbsense
//
//  Created by ruckef on 04/04/2021.
//

import Foundation

enum AbsenseType: Int, CaseIterable {
    case vacation
    case workFromHome
    case sickLeave
    case personalDay
}

struct Absense {
    let id: String
    var type: AbsenseType
    var dates: [CalendarDate]
    var comment: String?
    var attachments: Set<URL>
}

struct CalendarMonthData {
    let month: Int
    let year: Int
    let days: Int
}

struct CalendarDate {
    let year: Int
    let month: Int
    let day: Int
    
    var date: Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
}

struct CalendarCellItemData {
    enum CellType {
        case date(CalendarDate)
        case empty
    }

    let type: CellType
    var isSelected: Bool
}

struct ScheduleData {
    var type: AbsenseType
    var dates: [CalendarDate]
    var comment: String?
    var attachments: Set<URL>
    
    init(type: AbsenseType = .vacation,
         dates: [CalendarDate] = [],
         comment: String? = nil,
         attachments: Set<URL> = .init()) {
        self.type = type
        self.dates = dates
        self.comment = comment
        self.attachments = attachments
    }
}
