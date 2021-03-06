//
//  Created by Aleksander Grzyb on 17/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import Foundation

struct Note {
    let uid: Int
    let subject: String
    let detail: String
    var date: String?
}

extension Note {
    init?(dictionary: JSONDictionary) {
        guard let uid = dictionary["id"] as? Int,
            let subject = dictionary["subject"] as? String,
            let detail = dictionary["detail"] as? String else { return nil }
        self.uid = uid
        self.subject = subject
        self.detail = detail
        if let date = dictionary["date"] as? String {
            self.date = date
        }
    }
}
