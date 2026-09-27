import Foundation
import Observation

@Observable
final class DashboardViewModel {

    func todaysTasks(_ tasks: [Task]) -> [Task] {
        let todayWeekday = DateUtilities.weekday(of: .now)
        return tasks.filter { $0.isActive && $0.weekday == todayWeekday }
    }

    func pendingCount(_ tasks: [Task]) -> Int {
        todaysTasks(tasks).filter { task in
            let record = task.records.first { DateUtilities.isSameDay($0.occurrenceDate, .now) }
            return record == nil || record?.status == .pending
        }.count
    }

    func completedCount(_ tasks: [Task]) -> Int {
        todaysTasks(tasks).filter { task in
            task.records.first { DateUtilities.isSameDay($0.occurrenceDate, .now) }?.status == .completed
        }.count
    }

    func recentExpenses(_ expenses: [Expense], limit: Int = 5) -> [Expense] {
        expenses.sorted { $0.date > $1.date }.prefix(limit).map { $0 }
    }

    func upcomingRecurringExpenses(_ expenses: [Expense], limit: Int = 5) -> [Expense] {
        expenses
            .filter { $0.isRecurring && $0.date >= .now }
            .sorted { $0.date < $1.date }
            .prefix(limit)
            .map { $0 }
    }
}
