import Foundation
import SwiftData

@Model
final class Task {
    @Attribute(.unique) var id: UUID
    var name: String
    var taskDescription: String
    var weekday: Int          // 1 = domingo ... 7 = sábado (Calendar.current convention)
    var hour: Int             // 0-23
    var minute: Int           // 0-59
    var isActive: Bool
    var createdAt: Date
    var deactivatedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \TaskRecord.task)
    var records: [TaskRecord] = []

    @Relationship(inverse: \Note.linkedTask)
    var notes: [Note] = []

    init(
        id: UUID = UUID(),
        name: String,
        taskDescription: String = "",
        weekday: Int,
        hour: Int,
        minute: Int = 0,
        isActive: Bool = true,
        createdAt: Date = .now,
        deactivatedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.taskDescription = taskDescription
        self.weekday = weekday
        self.hour = hour
        self.minute = minute
        self.isActive = isActive
        self.createdAt = createdAt
        self.deactivatedAt = deactivatedAt
    }
}
