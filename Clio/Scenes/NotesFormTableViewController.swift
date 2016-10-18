//
//  Created by Aleksander Grzyb on 18/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import UIKit

class NotesFormTableViewController: UITableViewController {

    @IBOutlet weak var subjectTextView: UITextView!
    @IBOutlet weak var detailTextView: UITextView!

    var matter: Matter?
    var note: Note?

    enum State {
        case editing
        case loading
        case loaded(Note)
        case error(Error)
    }

    fileprivate var state: State = .editing {
        didSet {
            navigationItem.rightBarButtonItem = rightBarButtonItem(for: state)
            switch state {
            case .loading:
                subjectTextView?.isEditable = false
                subjectTextView?.isSelectable = false
                subjectTextView?.resignFirstResponder()
                detailTextView?.isEditable = false
                detailTextView?.isSelectable = false
                detailTextView?.resignFirstResponder()
            default:
                subjectTextView?.isEditable = true
                subjectTextView?.isSelectable = true
                detailTextView?.isEditable = true
                detailTextView?.isSelectable = true
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        state = .editing
        switch state {
        case .editing:
            if let note = note {
                navigationItem.leftBarButtonItem = nil
                setUpTextViews(with: note)
            } else {
                setUpPlaceholdersForTextViews()
            }
        default: break
        }
    }

    // MARK: Actions

    func saveNote(_ sender: UIBarButtonItem) {
        switch state {
        case .editing:
            if let note = note {
                edit(note: note)
            } else {
                createNote()
            }
        default: break
        }
    }

    // MARK: Private methods

    fileprivate func edit(note: Note) {
        state = .loading
        APIClient().load(resource: Note.editNote(subject: subjectText(),
                                                 detail: detailText(),
                                                 date: dateText(),
                                                 noteId: note.uid)) { result in
                                                    switch result {
                                                    case .success(let note):
                                                        self.state = .loaded(note)
                                                        self.unwindToNotesList()
                                                    case .failure(let error):
                                                        self.state = .error(error)
                                                        self.presentAlert(for: error)
                                                    }
        }
    }

    fileprivate func createNote() {
        state = .loading
        guard let matter = matter else {
            state = .editing
            return
        }
        APIClient().load(resource: Note.createNote(subject: subjectText(),
                                                   detail: detailText(),
                                                   date: dateText(),
                                                   matterId: matter.uid)) { result in
            switch result {
            case .success(let note):
                self.state = .loaded(note)
                self.unwindToNotesList()
            case .failure(let error):
                self.state = .error(error)
                self.presentAlert(for: error)
            }
        }
    }

    fileprivate func setUpPlaceholdersForTextViews() {
        subjectTextView.text = Placeholder.subject
        subjectTextView.textColor = UIColor.lightGray
        subjectTextView.delegate = self
        detailTextView.text = Placeholder.detail
        detailTextView.textColor = UIColor.lightGray
        detailTextView.delegate = self
    }

    fileprivate func setUpTextViews(with note: Note) {
        subjectTextView.text = note.subject
        detailTextView.text = note.detail
    }

    fileprivate func detailText() -> String {
        if detailTextView.text == Placeholder.detail || detailTextView.text.isEmpty {
            return Note.defaultDetail
        }
        return detailTextView.text
    }

    fileprivate func subjectText() -> String {
        if subjectTextView.text == Placeholder.subject || subjectTextView.text.isEmpty {
            return Note.defaultSubject
        }
        return subjectTextView.text
    }

    fileprivate func dateText() -> String {
        return Note.defaultDate
    }

    fileprivate func presentAlert(for error: Error) {
        let alertController = UIAlertController(title: "Error occured during saving.",
                                                message: error.localizedDescription,
                                                preferredStyle: .actionSheet)
        present(alertController, animated: true) { 
            self.state = .editing
        }
    }

    fileprivate func unwindToNotesList() {
        self.performSegue(withIdentifier: SegueIdentifier.unwindAfterNoteCreation, sender: self)
    }

    fileprivate func rightBarButtonItem(for state: State) -> UIBarButtonItem {
        switch state {
        case .loading(_):
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.startAnimating()
            return UIBarButtonItem(customView: activityIndicator)
        case .editing(_), .loaded(_), .error(_):
            return UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNote(_:)))
        }
    }
}

extension NotesFormTableViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Placeholder.subject || textView.text == Placeholder.detail {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        switch state {
        case .loading, .error(_): return false
        case .editing, .loaded(_): return true
        }
    }
}
