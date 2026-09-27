import Foundation
import UserNotifications

/// Encapsula toda la interacción con UserNotifications.
/// Responsable de solicitar permiso y programar/cancelar notificaciones
/// locales para tareas activas y gastos recurrentes habilitados.
final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private var center: UNUserNotificationCenter { .current() }

    // MARK: - Permiso

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Error solicitando permiso de notificaciones: \(error)")
            return false
        }
    }

    // MARK: - Tareas

    /// Identificador determinístico para la notificación repetitiva de una tarea.
    private func taskNotificationId(for task: Task) -> String {
        "task-\(task.id.uuidString)"
    }

    /// Programa (o reemplaza) la notificación semanal repetitiva de una tarea activa.
    func scheduleNotification(for task: Task) {
        cancelNotification(for: task)
        guard task.isActive else { return }

        let content = UNMutableNotificationContent()
        content.title = task.name
        content.body = task.taskDescription.isEmpty ? "Tienes una tarea programada." : task.taskDescription
        content.sound = .default
        content.categoryIdentifier = Constants.notificationCategoryTask

        var dateComponents = DateComponents()
        dateComponents.weekday = task.weekday
        dateComponents.hour = task.hour
        dateComponents.minute = task.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: taskNotificationId(for: task), content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                print("Error programando notificación de tarea: \(error)")
            }
        }
    }

    /// Cancela la notificación de una tarea (al desactivarla, modificarla o eliminarla).
    func cancelNotification(for task: Task) {
        center.removePendingNotificationRequests(withIdentifiers: [taskNotificationId(for: task)])
    }

    // MARK: - Gastos recurrentes

    private func expenseNotificationId(for expense: Expense) -> String {
        "expense-\(expense.id.uuidString)"
    }

    /// Programa una notificación anual (dentro del año configurado) para un gasto recurrente habilitado.
    func scheduleNotification(for expense: Expense) {
        cancelNotification(for: expense)
        guard expense.isRecurring, expense.notificationEnabled, let day = expense.recurringDay, let year = expense.year else { return }

        let content = UNMutableNotificationContent()
        content.title = "Gasto recurrente: \(expense.name)"
        content.body = "Recuerda tu pago de \(CurrencyFormatter.string(from: expense.amount)) programado para hoy."
        content.sound = .default
        content.categoryIdentifier = Constants.notificationCategoryExpense

        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.day = day
        dateComponents.hour = 9
        dateComponents.minute = 0

        // Se dispara una vez al mes durante el año configurado (día fijo del mes).
        var monthlyComponents = dateComponents
        monthlyComponents.year = nil
        let trigger = UNCalendarNotificationTrigger(dateMatching: monthlyComponents, repeats: true)
        let request = UNNotificationRequest(identifier: expenseNotificationId(for: expense), content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                print("Error programando notificación de gasto recurrente: \(error)")
            }
        }
    }

    func cancelNotification(for expense: Expense) {
        center.removePendingNotificationRequests(withIdentifiers: [expenseNotificationId(for: expense)])
    }
}
