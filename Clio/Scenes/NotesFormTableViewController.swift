//
//  Created by Aleksander Grzyb on 18/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import UIKit

class NotesFormTableViewController: UITableViewController {

    @IBOutlet weak var subjectTextView: UITextView!
    @IBOutlet weak var detailTextView: UITextView!

    var matter: Matter?

    enum State {
        case editing(Note?)
        case loading
        case loaded(Note)
        case error(Error)
    }

    var state: State = .editing(nil) {
        didSet {
            switch state {
            case .loading:
                subjectTextView?.isEditable = false
                subjectTextView?.resignFirstResponder()
                detailTextView?.isEditable = false
                detailTextView?.resignFirstResponder()
            default:
                subjectTextView?.isEditable = true
                detailTextView?.isEditable = true
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        switch state {
        case .editing(let note):
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

    @IBAction func saveNote(_ sender: UIBarButtonItem) {
        switch state {
        case .editing(let note):
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
                                                        self.performSegue(withIdentifier: SegueIdentifier.unwindAfterNoteCreation, sender: self)
                                                        self.state = .loaded(note)
                                                    case .failure(let error):
                                                        self.state = .error(error)
                                                    }
        }
    }

    fileprivate func createNote() {
        state = .loading
        guard let matter = matter else {
            state = .editing(nil)
            return
        }
        APIClient().load(resource: Note.createNote(subject: subjectText(),
                                                   detail: detailText(),
                                                   date: dateText(),
                                                   matterId: matter.uid)) { result in
            switch result {
            case .success(let note):
                self.state = .loaded(note)
                self.performSegue(withIdentifier: SegueIdentifier.unwindAfterNoteCreation, sender: self)
            case .failure(let error):
                self.state = .error(error)
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
        case .loading: return false
        case .editing, .loaded(_), .error(_): return true
        }
    }
}
