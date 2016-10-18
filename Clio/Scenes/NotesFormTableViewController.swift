//
//  Created by Aleksander Grzyb on 18/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import UIKit

class NotesFormTableViewController: UITableViewController {

    var cancelBarButtonItemShouldBePresent = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if !cancelBarButtonItemShouldBePresent {
            navigationItem.leftBarButtonItem = nil
        }
    }
}
