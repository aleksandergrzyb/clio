//
//  Created by Aleksander Grzyb on 17/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import UIKit

class MattersTableViewController: UITableViewController {

    enum State {
        case loading
        case loaded([Matter])
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

        loadMatters()
    }

    private func loadMatters() {
        state = .loading
        APIClient().load(resource: Matter.all) { result in
            switch result {
            case .success(let matters):
                if matters.count == 0 {
                    self.state = .empty
                    return
                }
                self.state = .loaded(matters)
            case .failure(let error):
                self.state = .error(error)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.showNotes,
            let notesTableViewController = segue.destination as? NotesTableViewController,
            let selectedIndexPath = tableView.indexPathForSelectedRow {
                switch state {
                case .loaded(let matters):
                    notesTableViewController.selectedMatter = matters[selectedIndexPath.row]
                default: break
                }
        }
    }
}

extension MattersTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .loaded(let matters):
            return matters.count
        case .empty, .error(_), .loading:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .loaded(let matters):
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.matterCell,
                                                     for: indexPath)
            cell.textLabel?.text = matters[indexPath.row].name
            cell.detailTextLabel?.text = matters[indexPath.row].description
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
