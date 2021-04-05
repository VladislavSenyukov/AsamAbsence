//
//  Date+Extensions.swift
//  AsamAbsense
//
//  Created by ruckef on 04/04/2021.
//

import Foundation

extension Date {
    var startOfYear: Date {
        let components = Calendar.current.dateComponents([.year], from: self)
        return Calendar.current.date(from: components)!
    }
    
    var endOfYear: Date {
        var components = DateComponents()
        components.year = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfYear)!
    }
    
    var nextYear: Date {
        var components = DateComponents()
        components.year = 1
        return Calendar.current.date(byAdding: components, to: startOfYear)!
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var daysInYear: Int {
        return Calendar.current.range(of: .day, in: .year, for: self)?.count ?? 0
    }
    
    var yearIndex: Int {
        let components = Calendar.current.dateComponents([.year], from: self)
        return components.year ?? 0
    }
    
    var dayIndex: Int {
        return Calendar.current.ordinality(of: .day, in: .year, for: self) ?? 1
    }
    
    var weekdayIndex: Int {
        let components = Calendar.current.dateComponents([.weekday], from: self)
        return components.weekday ?? 1
    }
    
    var monthDataLayout: [CalendarMonthData] {
        var layout: [CalendarMonthData] = []
        let calendar = Calendar.current
        let year = self.yearIndex
        for month in (1...12) {
            let components = DateComponents(year: year, month: month)
            let date = calendar.date(from: components)!
            let days = calendar.range(of: .day, in: .month, for: date)!.count
            let monthData = CalendarMonthData(month: month, year: year, days: days)
            layout.append(monthData)
        }
        return layout
    }
}

extension DateInterval {
    var normalizedToCurrentYear: DateInterval {
        let now = Date()
        let startNormalized = start > now.startOfYear ? start : now.startOfYear
        let endNormalized = end < now.endOfYear ? end : now.endOfYear
        return DateInterval(start: startNormalized, end: endNormalized)
    }
    
    var dayCount: Int {
        return Int(duration / (Constants.daySeconds))
    }
}
