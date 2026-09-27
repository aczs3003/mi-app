import Foundation
import SwiftData
import Observation

@Observable
final class FinanceViewModel {
    private let context: ModelContext
    private let recurringService: RecurringExpenseService

    var errorMessage: String?

    init(context: ModelContext) {
        self.context = context
        self.recurringService = RecurringExpenseService(context: context)
    }

    // MARK: - Sueldo

    func setMonthlyIncome(amount: Double, month: Int, year: Int, existingIncome: MonthlyIncome?) {
        guard amount >= 0 else {
            errorMessage = "El sueldo no puede ser negativo."
            return
        }
        if let existingIncome {
            existingIncome.amount = amount
        } else {
            context.insert(MonthlyIncome(amount: amount, month: month, year: year))
        }
        try? context.save()
    }

    // MARK: - Gastos

    func createExpense(name: String, amount: Double, date: Date, category: ExpenseCategory?) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty, amount > 0 else {
            errorMessage = "Nombre y valor del gasto son obligatorios."
            return
        }
        let expense = Expense(name: name, amount: amount, date: date, category: category)
        context.insert(expense)
        try? context.save()
    }

    func updateExpense(_ expense: Expense, name: String, amount: Double, date: Date, category: ExpenseCategory?) {
        expense.name = name
        expense.amount = amount
        expense.date = date
        expense.category = category
        try? context.save()
    }

    func deleteExpense(_ expense: Expense) {
        NotificationService.shared.cancelNotification(for: expense)
        context.delete(expense)
        try? context.save()
    }

    // MARK: - Categorías

    func createCategory(name: String, type: ExpenseCategoryType) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El nombre de la categoría es obligatorio."
            return
        }
        context.insert(ExpenseCategory(name: name, type: type))
        try? context.save()
    }

    // MARK: - Gastos recurrentes

    func createRecurringExpense(name: String, amount: Double, day: Int, year: Int, category: ExpenseCategory?, notificationEnabled: Bool) {
        let template = recurringService.createRecurringExpense(
            name: name, amount: amount, day: day, year: year,
            category: category, notificationEnabled: notificationEnabled
        )
        recurringService.generateOccurrences(for: template)
    }

    /// Al detectar un año nuevo, se debe presentar la pantalla de configuración
    /// de recurrentes. Los valores del año anterior NO se copian automáticamente.
    func needsNewYearSetup(recurringExpenses: [Expense]) -> Bool {
        let existingYears = Set(recurringExpenses.compactMap { $0.year })
        return recurringService.needsNewYearConfiguration(existingRecurringYears: existingYears)
    }

    // MARK: - Totales

    func availableBalance(income: Double, expenses: [Expense], month: Date = .now) -> Double {
        let start = DateUtilities.startOfMonth(for: month)
        let end = DateUtilities.endOfMonth(for: month)
        let spent = expenses.filter { $0.date >= start && $0.date <= end }.reduce(0) { $0 + $1.amount }
        return income - spent
    }
}
