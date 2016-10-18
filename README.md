## iOS application for Clio interview

### Further improvements

* There is lots of code repetition between subclasses (state management, creating respective `UITableViewCell`s, handling loaded data) of `UITableViewController`s. Code could be moved to protocols with extensions.
* When pull to refresh is used on `UITableViewController` all data disappears, which doesn't look good. This could be improved for example by storing number of rows for already loaded data.
* Right now it's not possible to change date of the note. In `NotesFormTableViewController` there should be used a date picker for this action.
* Unit tests should be were created. `APIClient` and model classes were designed to be testable (for `APIClient` class network provider should be dependency injected, right now it's `URLSession.shared`).
* View models should be created to handle data formatting. Right now most of it is handled in Massive View Controller. 🙃
* More error codes could be created to handle different cases.
* There should be a warning when closing view controller after note edition without save action.