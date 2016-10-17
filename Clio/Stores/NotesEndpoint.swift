//
//  Created by Aleksander Grzyb on 17/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import Foundation

extension Note {
    /// Creates a resource for all notes.
    static func all(matterId: Int) -> Resource<[Note]> {
        let params = [ "regarding_type" : "Matter",
                       "regarding_id": "\(matterId)" ]
        return Resource(path: "notes", params: params) { json -> Result<[Note]> in
            guard let root = json as? JSONDictionary,
            let dictionaries = root["notes"] as? [JSONDictionary] else {
                return .failure(MatterResourceError.mappingFailed)
            }
            return .success(dictionaries.flatMap(Note.init))
        }
    }
}
