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

    private var state: State = .loading {
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

extension MattersTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        return cell
    }
}
