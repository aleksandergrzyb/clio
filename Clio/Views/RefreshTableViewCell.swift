//
//  Created by Aleksander Grzyb on 18/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import UIKit

class RefreshTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    static let nibName = "RefreshTableViewCell"
    static let cellReuseIdentifier = "RefreshTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func startAnimating() {
        activityIndicatorView?.startAnimating()
    }
}
