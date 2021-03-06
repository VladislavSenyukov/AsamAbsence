//
//  ScheduleViewController.swift
//  AsamAbsence
//
//  Created by ruckef on 04/05/2021.
//

import UIKit
import UniformTypeIdentifiers

protocol ScheduleViewControllerDelegate: AnyObject {
    func didCreateAbsence()
    func didUpdateAbsence()
}

class ScheduleViewController: LoadableViewController {
    private enum ScheduleCellItemType: String, CaseIterable {
        case dates
        case type
        case comment
        case attachments
    }
    
    weak var delegate: ScheduleViewControllerDelegate?
    private lazy var viewModel = AsamAbsenceApp.shared.makeScheduleModel()
    private var isEdit = false
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Schedule"
        viewModel.delegate = self
        
        let rightBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = rightBarButton
        cancelButton.isHidden = !isEdit
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cancelButton.layer.cornerRadius = cancelButton.frame.height / 2.0
        cancelButton.layer.masksToBounds = false
        cancelButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        cancelButton.layer.shadowColor = UIColor.asamGrey.cgColor
        cancelButton.layer.shadowOpacity = 0.5
        cancelButton.layer.shadowRadius = 8
        cancelButton.titleLabel?.numberOfLines = 1
        cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true
        cancelButton.titleLabel?.lineBreakMode = .byClipping
    }
    
    func updateScheduleWithDates(_ dates: [CalendarDate]) {
        viewModel.updateDates(dates)
    }
    
    func updateForEditingAbsence(_ absence: Absence) {
        isEdit = true
        viewModel.updateFromAbsence(absence)
    }
}

extension ScheduleViewController: ScheduleViewModelDelegate {
    func showLoading(_ isLoading: Bool) {
        showLoading(isLoading, completion: nil)
    }
    
    func showAbsenceCreated() {
        navigationController?.popViewController(animated: true)
        delegate?.didCreateAbsence()
    }
    
    func showAbsenceUpdated() {
        navigationController?.popViewController(animated: true)
        delegate?.didUpdateAbsence()
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
            cell.configure(cellType.rawValue.capitalized, text: viewModel.absenceTitle)
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
            let alert = UIAlertController(title: "Select absence type", message: nil, preferredStyle: .actionSheet)
            let actionHandler: (UIAlertAction) -> Void = { [weak self, weak alert] action in
                guard
                    let index = alert?.actions.firstIndex(of: action),
                    let newAbsenceType = AbsenceType(rawValue: index) else {
                    return
                }
                self?.viewModel.updateAbsenceType(newAbsenceType)
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
            AbsenceType.allCases.forEach {
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
            viewModel.updateAbsence()
        } else {
            viewModel.scheduleAbsence()
        }
    }
    
    @IBAction func cancelTapped() {
        let alert = UIAlertController(title: "Cancel absence",
                                      message: "Are you sure you want to cancel this record?",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            self?.viewModel.cancelAbsence()
        }
        alert.addAction(okAction)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.preferredAction = okAction
        present(alert, animated: true, completion: nil)
    }
}

extension AbsenceType {
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
