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

class CalendarDayCell: UICollectionViewCell {
    static let identifier = "CalendarDayCell"
    var data: CalendarMonthData?
    
    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var isTodayView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        yearLabel.isHidden = true
        isTodayView.isHidden = true
        isTodayView.backgroundColor = .asamGreen
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        isTodayView.layer.cornerRadius = isTodayView.frame.width / 2.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        data = nil
        isTodayView.isHidden = true
        yearLabel.isHidden = true
    }
    
    func configureWithData(_ data: CalendarMonthData?, isToday: Bool, dayIndex: Int) {
        guard let data = data else {
            dayLabel.text = ""
            return
        }
        self.data = data
        var dayText = data.days.description
        if data.days == 1 || isToday {
            dayText += " \(formatter.string(from: data.date))"
            yearLabel.isHidden = false
            yearLabel.text = data.year.description
        } else {
            yearLabel.isHidden = true
        }
        if isToday {
            isTodayView.isHidden = false
            dayLabel.textColor = .white
            yearLabel.textColor = .white
        } else {
            isTodayView.isHidden = true
            yearLabel.textColor = .lightGray
            if dayIndex < 5 {
                dayLabel.textColor = .asamGrey
            } else {
                dayLabel.textColor = .lightGray
            }
        }
        dayLabel.text = dayText
    }
}
