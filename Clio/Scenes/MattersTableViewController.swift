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
        loadMatters()

        tableView.register(UINib(nibName: InformationTableViewCell.nibName, bundle: nil),
                           forCellReuseIdentifier: InformationTableViewCell.cellReuseIdentifier)
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
}

extension MattersTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .loaded(let matters):
            return matters.count
        case .empty, .error(_):
            return 1
        case .loading:
            return 0
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
            return UITableViewCell()
        }
    }
}
