import Foundation
import SwiftData
import Observation

@Observable
final class TaskViewModel {
    private let context: ModelContext
    private let historyService: TaskHistoryService

    var errorMessage: String?

    init(context: ModelContext) {
        self.context = context
        self.historyService = TaskHistoryService(context: context)
    }

    // MARK: - CRUD

    func createTask(name: String, description: String, weekday: Int, hour: Int, minute: Int) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El nombre de la tarea es obligatorio."
            return
        }
        let task = Task(name: name, taskDescription: description, weekday: weekday, hour: hour, minute: minute)
        context.insert(task)
        try? context.save()
        NotificationService.shared.scheduleNotification(for: task)
    }

    func updateTask(_ task: Task, name: String, description: String, weekday: Int, hour: Int, minute: Int) {
        task.name = name
        task.taskDescription = description
        task.weekday = weekday
        task.hour = hour
        task.minute = minute
        try? context.save()
        // Reprogramar notificación con los nuevos datos.
        NotificationService.shared.scheduleNotification(for: task)
    }

    /// Las tareas nunca se eliminan físicamente: solo se desactivan,
    /// conservando su historial de TaskRecord para estadísticas.
    func deactivate(_ task: Task) {
        task.isActive = false
        task.deactivatedAt = .now
        try? context.save()
        NotificationService.shared.cancelNotification(for: task)
    }

    func reactivate(_ task: Task) {
        task.isActive = true
        task.deactivatedAt = nil
        try? context.save()
        NotificationService.shared.scheduleNotification(for: task)
    }

    // MARK: - Cumplimiento

    func markCompleted(_ task: Task) {
        historyService.markCompleted(task)
    }

    func markMissed(_ task: Task) {
        historyService.markMissed(task)
    }

    func closeOverdueRecords(tasks: [Task]) {
        historyService.closeOverdueRecords(tasks: tasks)
    }

    func todayRecord(for task: Task) -> TaskRecord? {
        task.records.first { DateUtilities.isSameDay($0.occurrenceDate, .now) }
    }
}
