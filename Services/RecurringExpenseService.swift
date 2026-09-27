import Foundation
import SwiftData

/// Encapsula la lógica de gastos recurrentes: creación por año, generación de
/// ocurrencias mensuales, finalización en diciembre y solicitud de nueva
/// configuración al iniciar un año nuevo. Los valores de un año NO se copian
/// automáticamente como definitivos al año siguiente.
final class RecurringExpenseService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Crea la plantilla de un gasto recurrente para un año específico.
    @discardableResult
    func createRecurringExpense(
        name: String,
        amount: Double,
        day: Int,
        year: Int,
        category: ExpenseCategory?,
        notificationEnabled: Bool
    ) -> Expense {
        let expense = Expense(
            name: name,
            amount: amount,
            date: DateUtilities.date(year: year, month: DateUtilities.currentMonth(), day: min(day, 28)) ?? .now,
            category: category,
            isRecurring: true,
            recurringDay: day,
            year: year,
            notificationEnabled: notificationEnabled
        )
        context.insert(expense)
        try? context.save()

        if notificationEnabled {
            NotificationService.shared.scheduleNotification(for: expense)
        }
        return expense
    }

    /// Genera (si no existen) las ocurrencias mensuales de un gasto recurrente
    /// desde enero hasta diciembre del año configurado.
    func generateOccurrences(for template: Expense) -> [Expense] {
        guard template.isRecurring, let day = template.recurringDay, let year = template.year else { return [] }

        var occurrences: [Expense] = []
        for month in 1...12 {
            guard let date = DateUtilities.date(year: year, month: month, day: min(day, 28)) else { continue }
            let occurrence = Expense(
                name: template.name,
                amount: template.amount,
                date: date,
                category: template.category,
                isRecurring: true,
                recurringDay: day,
                year: year,
                notificationEnabled: template.notificationEnabled
            )
            context.insert(occurrence)
            occurrences.append(occurrence)
        }
        try? context.save()
        return occurrences
    }

    /// Verifica si ya cambiamos de año respecto al último gasto recurrente
    /// configurado, para solicitar al usuario una nueva configuración.
    func needsNewYearConfiguration(existingRecurringYears: Set<Int>, currentYear: Int = DateUtilities.currentYear()) -> Bool {
        !existingRecurringYears.contains(currentYear)
    }

    /// Todos los gastos recurrentes "finalizan" automáticamente el 31 de
    /// diciembre porque están asociados a un año específico: no se requiere
    /// borrado explícito, basta con no generar ocurrencias para el año nuevo
    /// hasta que el usuario configure uno nuevo.
    func recurringTemplates(from allExpenses: [Expense], year: Int) -> [Expense] {
        allExpenses.filter { $0.isRecurring && $0.year == year }
    }
}
