import Foundation
import SwiftData

enum TaskRecordStatus: String, Codable, CaseIterable {
    case pending
    case completed
    case missed
}

@Model
final class TaskRecord {
    @Attribute(.unique) var id: UUID
    var occurrenceDate: Date
    var status: TaskRecordStatus
    var completedAt: Date?

    var task: Task?

    init(
        id: UUID = UUID(),
        occurrenceDate: Date,
        status: TaskRecordStatus = .pending,
        completedAt: Date? = nil,
        task: Task? = nil
    ) {
        self.id = id
        self.occurrenceDate = occurrenceDate
        self.status = status
        self.completedAt = completedAt
        self.task = task
    }
}
