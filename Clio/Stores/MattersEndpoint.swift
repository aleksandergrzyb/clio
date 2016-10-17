//
//  Created by Aleksander Grzyb on 17/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import Foundation

/// Represents possible errors that could occur when using `Matter` resource.
///
/// - mappingFailed:    Mapping from JSON to object failed.
enum MatterResourceError: Error {
    case mappingFailed
}

extension MatterResourceError {
    var localizedDescription: String {
        switch self {
        case .mappingFailed:
            return "Data for matters is in unexpected format. Please try again later."
        }
    }
}


extension Matter {

    /// Creates a resource for all matters.
    static let all = Resource(path: "matters") { json -> Result<[Matter]> in
        guard let root = json as? JSONDictionary,
            let dictionaries = root["matters"] as? [JSONDictionary] else {
                return .failure(MatterResourceError.mappingFailed)
        }
        return .success(dictionaries.flatMap(Matter.init))
    }
}
