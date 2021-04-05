//
//  ScheduleViewController.swift
//  AsamAbsense
//
//  Created by ruckef on 04/05/2021.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didCreateAbsense()
    func didUpdateAbsense()
}

class ScheduleViewController: LoadableViewController {
    private enum ScheduleCellItemType: String, CaseIterable {
        case dates
        case type
        case comment
        case attachments
    }
    
    weak var delegate: ScheduleViewControllerDelegate?
    private lazy var viewModel = AsamAbsenseApp.shared.makeScheduleModel()
    private var isEdit = false
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Schedule"
        viewModel.delegate = self
        
        let rightBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func updateScheduleWithDates(_ dates: [CalendarDate]) {
        viewModel.updateDates(dates)
    }
    
    func updateForEditingAbsense(_ absense: Absense) {
        isEdit = true
        viewModel.updateFromAbsense(absense)
    }
}

extension ScheduleViewController: ScheduleViewModelDelegate {
    func showLoading(_ isLoading: Bool) {
        showLoading(isLoading, completion: nil)
    }
    
    func showAbsenseCreated() {
        navigationController?.popViewController(animated: true)
        delegate?.didCreateAbsense()
    }
    
    func showAbsenseUpdated() {
        navigationController?.popViewController(animated: true)
        delegate?.didUpdateAbsense()
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return ScheduleCellItemType.allCases.count
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = ScheduleCellItemType.allCases[indexPath.row]
        switch cellType {
        case .dates:
            let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTitleCell.cellIdentifier) as! ScheduleTitleCell
            cell.configure(cellType.rawValue.capitalized, text: viewModel.datesString)
            return cell
        case .type:
            let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTitleCell.cellIdentifier) as! ScheduleTitleCell
            cell.configure(cellType.rawValue.capitalized, text: viewModel.absenseTitle)
            return cell
        case .comment:
            return UITableViewCell()
        case .attachments:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = ScheduleCellItemType.allCases[indexPath.row]
        switch cellType {
        case .type:
            let alert = UIAlertController(title: "Select absense type", message: nil, preferredStyle: .actionSheet)
            let actionHandler: (UIAlertAction) -> Void = { [weak self, weak alert] action in
                guard
                    let index = alert?.actions.firstIndex(of: action),
                    let newAbsenseType = AbsenseType(rawValue: index) else {
                    return
                }
                self?.viewModel.updateAbsenseType(newAbsenseType)
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
            AbsenseType.allCases.forEach {
                alert.addAction(UIAlertAction(title: $0.title, style: .default, handler: actionHandler))
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        case .attachments, .comment, .dates:
            break
        }
    }
}

private extension ScheduleViewController {
    @objc func doneTapped() {
        if isEdit {
            viewModel.updateAbsense()
        } else {
            viewModel.scheduleAbsense()
        }
    }
}

extension AbsenseType {
    var title: String {
        switch self {
        case .vacation:
            return "Vacation"
        case .sickLeave:
            return "Sick Leave"
        case .workFromHome:
            return "Work From Home"
        case .personalDay:
             return "Personal Day"
        }
    }
}
