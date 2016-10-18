//
//  Created by Aleksander Grzyb on 17/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import Foundation

/// Represents possible errors that could occur when using `Note` resource.
///
/// - mappingFailed:    Mapping from JSON to object failed.
enum NotesResourceError: Error {
    case mappingFailed
}

extension Note {
    /// Returns all notes for given matter ID.
    static func all(matterId: Int) -> Resource<[Note]> {
        let params = [ "regarding_type": "Matter",
                       "regarding_id": "\(matterId)" ]
        return Resource(path: "notes", params: params) { json -> Result<[Note]> in
            guard let root = json as? JSONDictionary,
            let dictionaries = root["notes"] as? [JSONDictionary] else {
                return .failure(NotesResourceError.mappingFailed)
            }
            return .success(dictionaries.flatMap(Note.init))
        }
    }

    /// Creates note with given data for matter ID.
    static func createNote(subject: String = "Default subject",
                           detail: String = "Default detail",
                           date: String = "2000-01-01",
                           matterId: Int) -> Resource<Note> {
        let regarding = [ "type" : "Matter", "id": "\(matterId)" ]
        let note: JSONDictionary = [ "subject": subject, "detail": detail, "regarding": regarding ]
        let body: JSONDictionary = [ "note": note ]
        return Resource(path: "notes", method: .post(body)) { json -> Result<Note> in
            guard let root = json as? JSONDictionary,
                let noteDictionary = root["note"] as? JSONDictionary,
                let note = Note.init(dictionary: noteDictionary) else {
                return .failure(NotesResourceError.mappingFailed)
            }
            return .success(note)
        }
    }
}
