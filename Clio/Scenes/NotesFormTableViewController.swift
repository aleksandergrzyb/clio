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
    }

    // MARK: Private methods

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
}
