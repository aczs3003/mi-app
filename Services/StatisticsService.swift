import Foundation

struct TaskStatsPoint: Identifiable {
    let id = UUID()
    let label: String
    let completed: Int
    let missed: Int
}

struct CategoryExpenseStat: Identifiable {
    let id = UUID()
    let categoryName: String
    let total: Double
}

/// Calcula agregaciones para las pantallas de estadísticas, a partir del
/// historial de TaskRecord y de los gastos registrados.
final class StatisticsService {

    // MARK: - Tareas

    func completionPercentage(records: [TaskRecord]) -> Double {
        let finished = records.filter { $0.status == .completed || $0.status == .missed }
        guard !finished.isEmpty else { return 0 }
        let completed = finished.filter { $0.status == .completed }.count
        return Double(completed) / Double(finished.count) * 100
    }

    func weeklyStats(records: [TaskRecord], weekStart: Date = DateUtilities.startOfWeek()) -> [TaskStatsPoint] {
        let cal = DateUtilities.calendar
        var points: [TaskStatsPoint] = []
        for offset in 0..<7 {
            guard let day = cal.date(byAdding: .day, value: offset, to: weekStart) else { continue }
            let dayRecords = records.filter { DateUtilities.isSameDay($0.occurrenceDate, day) }
            let completed = dayRecords.filter { $0.status == .completed }.count
            let missed = dayRecords.filter { $0.status == .missed }.count
            points.append(TaskStatsPoint(label: shortWeekdayLabel(day), completed: completed, missed: missed))
        }
        return points
    }

    func monthlyEvolution(records: [TaskRecord], monthsBack: Int = 6, reference: Date = .now) -> [TaskStatsPoint] {
        let cal = DateUtilities.calendar
        var points: [TaskStatsPoint] = []
        for offset in stride(from: monthsBack - 1, through: 0, by: -1) {
            guard let monthDate = cal.date(byAdding: .month, value: -offset, to: reference) else { continue }
            let start = DateUtilities.startOfMonth(for: monthDate)
            let end = DateUtilities.endOfMonth(for: monthDate)
            let monthRecords = records.filter { $0.occurrenceDate >= start && $0.occurrenceDate <= end }
            let completed = monthRecords.filter { $0.status == .completed }.count
            let missed = monthRecords.filter { $0.status == .missed }.count
            points.append(TaskStatsPoint(label: monthLabel(monthDate), completed: completed, missed: missed))
        }
        return points
    }

    // MARK: - Finanzas

    func totalByCategory(expenses: [Expense]) -> [CategoryExpenseStat] {
        let grouped = Dictionary(grouping: expenses) { $0.category?.name ?? "Sin categoría" }
        return grouped.map { CategoryExpenseStat(categoryName: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    func weeklyExpenseTotal(expenses: [Expense], weekStart: Date = DateUtilities.startOfWeek()) -> Double {
        let weekEnd = DateUtilities.endOfWeek(for: weekStart)
        return expenses.filter { $0.date >= weekStart && $0.date <= weekEnd }.reduce(0) { $0 + $1.amount }
    }

    func monthlyExpenseTotal(expenses: [Expense], month: Date = .now) -> Double {
        let start = DateUtilities.startOfMonth(for: month)
        let end = DateUtilities.endOfMonth(for: month)
        return expenses.filter { $0.date >= start && $0.date <= end }.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Helpers

    private func shortWeekdayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Constants.localeIdentifier)
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).capitalized
    }

    private func monthLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Constants.localeIdentifier)
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).capitalized
    }
}
