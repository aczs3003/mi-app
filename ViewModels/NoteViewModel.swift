import Foundation
import SwiftData
import Observation

@Observable
final class NoteViewModel {
    private let context: ModelContext
    var errorMessage: String?

    init(context: ModelContext) {
        self.context = context
    }

    func createNote(title: String, content: String, linkedTask: Task?) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El título de la nota es obligatorio."
            return
        }
        let note = Note(title: title, content: content, linkedTask: linkedTask)
        context.insert(note)
        try? context.save()
    }

    func updateNote(_ note: Note, title: String, content: String, linkedTask: Task?) {
        note.title = title
        note.content = content
        note.linkedTask = linkedTask
        note.updatedAt = .now
        try? context.save()
    }

    func deleteNote(_ note: Note) {
        context.delete(note)
        try? context.save()
    }
}
