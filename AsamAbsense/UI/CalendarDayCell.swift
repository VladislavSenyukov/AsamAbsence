//
//  CalendarDayCell.swift
//  AsamAbsense
//
//  Created by ruckef on 04/05/2021.
//

import UIKit

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"
    return formatter
}()

struct CalendarCellViewData {
    let type: CalendarCellItemData.CellType
    let isSelected: Bool
    let dayIndex: Int
    let isToday: Bool
}

class CalendarDayCell: UICollectionViewCell {
    static let identifier = "CalendarDayCell"
    var data: CalendarCellViewData?
    
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var isTodayView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isTodayView.backgroundColor = .asamGreen
        contentView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        isTodayView.layer.cornerRadius = isTodayView.frame.width / 2.0
        contentView.layer.cornerRadius = 5
    }
    
    func configureWithData(_ data: CalendarCellViewData) {
        self.data = data
        switch data.type {
        case .empty:
            dayLabel.isHidden = true
            yearLabel.isHidden = true
            isTodayView.isHidden = true
        case .date(let calendarDate):
            dayLabel.isHidden = false
            yearLabel.isHidden = true
            isTodayView.isHidden = true
            
            let day = calendarDate.day
            var dayText = day.description
            if day == 1 || data.isToday || data.isSelected {
                dayText += " \(formatter.string(from: calendarDate.date))"
                yearLabel.isHidden = false
                yearLabel.text = calendarDate.year.description
            } else if day == 0 {
                dayText = ""
            }
            dayLabel.text = dayText
            
            if data.isToday || data.isSelected {
                dayLabel.textColor = .white
                yearLabel.textColor = .white
            } else {
                yearLabel.textColor = .lightGray
                if data.dayIndex < 5 {
                    dayLabel.textColor = .asamGrey
                } else {
                    dayLabel.textColor = .lightGray
                }
            }
            isTodayView.isHidden = !data.isToday
        }
        if data.isSelected {
            contentView.backgroundColor = UIColor(hex: "#307030FF")
        } else {
            contentView.backgroundColor = .white
        }
    }
}
