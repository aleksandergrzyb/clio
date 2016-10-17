//
//  Created by Aleksander Grzyb on 17/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import UIKit

class InformationTableViewCell: UITableViewCell {

    @IBOutlet weak var informationLabel: UILabel!
    
    enum Kind {
        case error(String)
        case information(String)
    }

    func configureWith(kind: Kind) {
        switch kind {
        case .error(let message):
            informationLabel.textColor = .red
            informationLabel.text = message
        case .information(let message):
            informationLabel.textColor = .black
            informationLabel.text = message
        }
    }
}
