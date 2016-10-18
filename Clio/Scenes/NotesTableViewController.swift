//
//  Created by Aleksander Grzyb on 17/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import UIKit

class NotesTableViewController: UITableViewController {

    var selectedMatter: Matter?

    enum State {
        case loading
        case loaded([Note])
        case empty
        case error(Error)
    }

    fileprivate var state: State = .loading {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: InformationTableViewCell.nibName, bundle: nil),
                           forCellReuseIdentifier: InformationTableViewCell.cellReuseIdentifier)

        loadNotes()
    }

    private func loadNotes() {
        guard let matter = selectedMatter else {
            return
        }
        state = .loading
        APIClient().load(resource: Note.all(matterId: matter.uid)) { result in
            switch result {
            case .success(let notes):
                if notes.count == 0 {
                    self.state = .empty
                    return
                }
                self.state = .loaded(notes)
            case .failure(let error):
                self.state = .error(error)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let notesFormNC = segue.destination as? UINavigationController,
            let notesFormTableViewController = notesFormNC.topViewController as? NotesFormTableViewController,
            segue.identifier == SegueIdentifier.showNotesFormForCreation {
                notesFormTableViewController.state = .editing(nil)
                notesFormTableViewController.matter = selectedMatter
        }

        if let notesFormTableViewController = segue.destination as? NotesFormTableViewController,
            segue.identifier == SegueIdentifier.showNotesFormForEdition,
            let selectedIndexPath = tableView.indexPathForSelectedRow {
                switch state {
                case .loaded(let notes):
                    notesFormTableViewController.state = .editing(notes[selectedIndexPath.row])
                default: break
                }
                notesFormTableViewController.matter = selectedMatter
        }
    }

    @IBAction func unwindFromNoteForm(for segue: UIStoryboardSegue) {
        if segue.identifier == SegueIdentifier.unwindAfterNoteCreation {
            loadNotes()
        }
    }
}

extension NotesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .loaded(let notes):
            return notes.count
        case .empty, .error(_), .loading:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .loaded(let notes):
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.noteCell, for: indexPath)
            cell.textLabel?.text = notes[indexPath.row].subject
            cell.detailTextLabel?.text = notes[indexPath.row].date
            return cell
        case .empty:
            let cell = tableView.dequeueReusableCell(withIdentifier: InformationTableViewCell.cellReuseIdentifier,
                                                     for: indexPath) as! InformationTableViewCell
            cell.configureWith(kind: .information("You have no matters right now."))
            return cell
        case .error(let error):
            let cell = tableView.dequeueReusableCell(withIdentifier: InformationTableViewCell.cellReuseIdentifier,
                                                     for: indexPath) as! InformationTableViewCell
            cell.configureWith(kind: .error(error.localizedDescription))
            return cell
        case .loading:
            return tableView.dequeueReusableCell(withIdentifier: CellIdentifier.refreshCell,
                                                 for: indexPath)
        }
    }
}
