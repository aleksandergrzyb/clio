//
//  Created by Aleksander Grzyb on 17/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import Foundation

struct Matter {
    let uid: Int
    let name: String
    let description: String
}

extension Matter {
    init?(dictionary: JSONDictionary) {
        guard let uid = dictionary["id"] as? Int,
            let name = dictionary["display_number"] as? String,
            let description = dictionary["description"] as? String else { return nil }
        self.uid = uid
        self.name = name
        self.description = description
    }
}
