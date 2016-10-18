//
//  Created by Aleksander Grzyb on 17/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import UIKit

class NotesTableViewController: UITableViewController {

    // MARK: Public methods/properties

    var matter: Matter?

    enum State {
        case loading(Bool)
        case loaded([Note])
        case empty
        case error(Error)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        cofigureTableView()
        loadNotes(fromRefreshControl: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let notesFormNC = segue.destination as? UINavigationController,
            let notesFormTableViewController = notesFormNC.topViewController as? NotesFormTableViewController,
            segue.identifier == SegueIdentifier.showNotesFormForCreation {
                notesFormTableViewController.matter = matter
        }

        if let notesFormTableViewController = segue.destination as? NotesFormTableViewController,
            segue.identifier == SegueIdentifier.showNotesFormForEdition,
            let selectedIndexPath = tableView.indexPathForSelectedRow {
                switch state {
                case .loaded(let notes):
                    notesFormTableViewController.note = notes[selectedIndexPath.row]
                default: break
                }
                notesFormTableViewController.matter = matter
        }
    }

    // MARK: Actions

    @IBAction func unwindFromNoteForm(for segue: UIStoryboardSegue) {
        if segue.identifier == SegueIdentifier.unwindAfterNoteCreation {
            loadNotes(fromRefreshControl: false)
        }
    }

    @IBAction func refreshPulled(_ sender: UIRefreshControl) {
        switch state {
        case .loading(_):
            return
        default:
            loadNotes(fromRefreshControl: true)
        }
    }

    // MARK: Private methods/properties

    fileprivate var state: State = .loading(false) {
        didSet {
            tableView.reloadData()
            switch state {
            case .error(_), .loaded(_):
                refreshControl?.endRefreshing()
            default: break
            }
        }
    }

    private func cofigureTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: InformationTableViewCell.nibName, bundle: nil),
                           forCellReuseIdentifier: InformationTableViewCell.cellReuseIdentifier)
        tableView.register(UINib(nibName: RefreshTableViewCell.nibName, bundle: nil),
                           forCellReuseIdentifier: RefreshTableViewCell.cellReuseIdentifier)
    }

    private func loadNotes(fromRefreshControl: Bool) {
        guard let matter = matter else {
            return
        }
        state = .loading(fromRefreshControl)
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
}

extension NotesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .loaded(let notes):
            return notes.count
        case .empty, .error(_):
            return 1
        case .loading(let fromRefreshControl):
            return fromRefreshControl ? 0 : 1
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
        case .loading(let fromRefreshControl):
            if fromRefreshControl {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: RefreshTableViewCell.cellReuseIdentifier,
                                                     for: indexPath) as! RefreshTableViewCell
            cell.startAnimating()
            return cell
        }
    }
}
