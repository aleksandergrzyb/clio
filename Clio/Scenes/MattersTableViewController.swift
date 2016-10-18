//
//  Created by Aleksander Grzyb on 17/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import UIKit

class MattersTableViewController: UITableViewController {

    // Public methods/properties

    enum State {
        case loading
        case loaded([Matter])
        case empty
        case error(Error)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        cofigureTableView()
        loadMatters()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.showNotes,
            let notesTableViewController = segue.destination as? NotesTableViewController,
            let selectedIndexPath = tableView.indexPathForSelectedRow {
                switch state {
                case .loaded(let matters):
                    notesTableViewController.matter = matters[selectedIndexPath.row]
                default: break
                }
        }
    }

    // MARK: Private methods/properties

    fileprivate var state: State = .loading {
        didSet {
            tableView.reloadData()
        }
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

    private func cofigureTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: InformationTableViewCell.nibName, bundle: nil),
                           forCellReuseIdentifier: InformationTableViewCell.cellReuseIdentifier)
        tableView.register(UINib(nibName: RefreshTableViewCell.nibName, bundle: nil),
                           forCellReuseIdentifier: RefreshTableViewCell.cellReuseIdentifier)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: RefreshTableViewCell.cellReuseIdentifier,
                                                     for: indexPath) as! RefreshTableViewCell
            cell.startAnimating()
            return cell
        }
    }
}
