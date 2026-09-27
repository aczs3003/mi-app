import Foundation
import SwiftData

/// Encapsula la generación y actualización del historial (TaskRecord) de una tarea.
final class TaskHistoryService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Genera el TaskRecord correspondiente a la ocurrencia de hoy, si la tarea
    /// está activa y aún no existe un registro para esa fecha.
    @discardableResult
    func ensureTodayRecord(for task: Task, on date: Date = .now) -> TaskRecord? {
        guard task.isActive else { return nil }
        guard DateUtilities.weekday(of: date) == task.weekday else { return nil }

        if let existing = task.records.first(where: { DateUtilities.isSameDay($0.occurrenceDate, date) }) {
            return existing
        }

        let record = TaskRecord(occurrenceDate: date, status: .pending, task: task)
        task.records.append(record)
        context.insert(record)
        try? context.save()
        return record
    }

    /// Marca como cumplida la ocurrencia de hoy (o la crea y la marca).
    func markCompleted(_ task: Task, on date: Date = .now) {
        let record = ensureTodayRecord(for: task, on: date) ?? task.records.first(where: { DateUtilities.isSameDay($0.occurrenceDate, date) })
        record?.status = .completed
        record?.completedAt = .now
        try? context.save()
    }

    /// Marca explícitamente una ocurrencia como no cumplida.
    func markMissed(_ task: Task, on date: Date = .now) {
        let record = ensureTodayRecord(for: task, on: date) ?? task.records.first(where: { DateUtilities.isSameDay($0.occurrenceDate, date) })
        record?.status = .missed
        record?.completedAt = nil
        try? context.save()
    }

    /// Recorre todas las tareas activas y marca como "missed" las ocurrencias
    /// vencidas que quedaron en estado pendiente (llamar al abrir la app).
    func closeOverdueRecords(tasks: [Task], now: Date = .now) {
        for task in tasks {
            for record in task.records where record.status == .pending {
                if record.occurrenceDate < DateUtilities.calendar.startOfDay(for: now) {
                    record.status = .missed
                }
            }
        }
        try? context.save()
    }
}
