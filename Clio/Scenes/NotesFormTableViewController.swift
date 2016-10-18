//
//  Created by Aleksander Grzyb on 18/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import UIKit

class NotesFormTableViewController: UITableViewController {

    @IBOutlet weak var subjectTextView: UITextView!
    @IBOutlet weak var detailTextView: UITextView!

    enum Mode {
        case edit
        case new
    }
    var mode: Mode = .edit

    enum State {
        case editing
        case loading
        case loaded([Matter])
        case error(Error)
    }

    fileprivate var state: State = .editing {
        didSet {
            switch state {
            case .loading:
                subjectTextView.resignFirstResponder()
                detailTextView.resignFirstResponder()
            default:
                break
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        switch mode {
        case .new:
            setUpPlaceholdersForTextViews()
        case .edit:
            navigationItem.leftBarButtonItem = nil
        }
    }

    // MARK: Actions

    @IBAction func saveNote(_ sender: UIBarButtonItem) {
        state = .loading
        switch mode {
        case .new:
            createNote()
        case .edit: break
        }
    }

    // MARK: Private methods

    fileprivate func createNote() {

    }

    fileprivate func setUpPlaceholdersForTextViews() {
        subjectTextView.text = Placeholder.subject
        subjectTextView.textColor = UIColor.lightGray
        subjectTextView.delegate = self
        detailTextView.text = Placeholder.detail
        detailTextView.textColor = UIColor.lightGray
        detailTextView.delegate = self
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
