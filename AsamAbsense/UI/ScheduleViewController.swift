//
//  ScheduleViewController.swift
//  AsamAbsense
//
//  Created by ruckef on 04/05/2021.
//

import UIKit
import UniformTypeIdentifiers

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
        return ScheduleCellItemType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = ScheduleCellItemType.allCases[indexPath.row]
        switch cellType {
        case .dates:
            let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTitleCell.identifier) as! ScheduleTitleCell
            cell.configure(cellType.rawValue.capitalized, text: viewModel.datesString)
            return cell
        case .type:
            let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTitleCell.identifier) as! ScheduleTitleCell
            cell.configure(cellType.rawValue.capitalized, text: viewModel.absenseTitle)
            return cell
        case .comment:
            let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCommentCell.identifier) as! ScheduleCommentCell
            cell.configure(cellType.rawValue.capitalized, comment: viewModel.comment)
            return cell
        case .attachments:
            let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTitleCell.identifier) as! ScheduleTitleCell
            cell.configure(cellType.rawValue.capitalized, text: viewModel.attachmentsString)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
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
        case .attachments:
            let documentVC = UIDocumentPickerViewController(forOpeningContentTypes: [.content])
            documentVC.delegate = self
            present(documentVC, animated: true, completion: nil)
        case .comment, .dates:
            break
        }
    }
}

extension ScheduleViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        guard let firstURL = urls.first else {
            return
        }
        viewModel.addAttachment(firstURL)
        tableView.reloadData()
    }
}

extension ScheduleViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange, with: string)
            viewModel.updateComment(updatedText)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
