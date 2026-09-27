import Foundation
import SwiftData

@Model
final class Note {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date

    var linkedTask: Task?

    init(
        id: UUID = UUID(),
        title: String,
        content: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now,
        linkedTask: Task? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.linkedTask = linkedTask
    }
}
