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
            switch state {
            case .loaded(_), .empty, .error(_):
                tableView.reloadData()
            default:
                break
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotes()

        tableView.register(UINib(nibName: InformationTableViewCell.nibName, bundle: nil),
                           forCellReuseIdentifier: InformationTableViewCell.cellReuseIdentifier)
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
}

extension NotesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .loaded(let notes):
            return notes.count
        case .empty, .error(_):
            return 1
        case .loading:
            return 0
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
            return UITableViewCell()
        }
    }
}
