//
//  Created by Aleksander Grzyb on 17/10/16.
//  Copyright © 2016 Aleksander Grzyb. All rights reserved.
//

import Foundation

/// Represents possible errors that could occur when using `Note` resource.
///
/// - mappingFailed:    Mapping from JSON to object failed.
enum NoteResourceError: Error {
    case mappingFailed
}

extension NoteResourceError {
    var localizedDescription: String {
        switch self {
        case .mappingFailed:
            return "Data for notes is in unexpected format. Please try again later."
        }
    }
}

extension Note {
    /// Returns all notes for given matter ID.
    static func all(matterId: Int) -> Resource<[Note]> {
        let params = [ "regarding_type": "Matter",
                       "regarding_id": "\(matterId)" ]
        return Resource(path: "notes", params: params) { json -> Result<[Note]> in
            guard let root = json as? JSONDictionary,
            let dictionaries = root["notes"] as? [JSONDictionary] else {
                return .failure(NoteResourceError.mappingFailed)
            }
            return .success(dictionaries.flatMap(Note.init))
        }
    }

    /// Creates note with given data for matter ID.
    static func createNote(subject: String,
                           detail: String,
                           date: String,
                           matterId: Int) -> Resource<Note> {
        let regarding = [ "type" : "Matter", "id": "\(matterId)" ]
        let note: JSONDictionary = [ "subject": subject, "detail": detail, "regarding": regarding ]
        let body: JSONDictionary = [ "note": note ]
        return Resource(path: "notes", method: .post(body)) { json -> Result<Note> in
            guard let root = json as? JSONDictionary,
                let noteDictionary = root["note"] as? JSONDictionary,
                let note = Note.init(dictionary: noteDictionary) else {
                return .failure(NoteResourceError.mappingFailed)
            }
            return .success(note)
        }
    }

    // Edits note with given data for note ID.
    static func editNote(subject: String,
                         detail: String,
                         date: String,
                         noteId: Int) -> Resource<Note> {
        let note: JSONDictionary = [ "subject": subject, "detail": detail ]
        let body: JSONDictionary = [ "note": note ]
        return Resource(path: "notes/\(noteId)", method: .put(body)) { json -> Result<Note> in
            guard let root = json as? JSONDictionary,
                let noteDictionary = root["note"] as? JSONDictionary,
                let note = Note.init(dictionary: noteDictionary) else {
                    return .failure(NoteResourceError.mappingFailed)
            }
            return .success(note)
        }
    }
}

extension Note {
    static let defaultSubject = "Default subject"
    static let defaultDetail = "Default detail"
    static let defaultDate = "2000-01-01"
}
