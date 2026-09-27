import Foundation
import Observation

@Observable
final class StatisticsViewModel {
    private let statisticsService = StatisticsService()

    // Tareas
    func completionPercentage(records: [TaskRecord]) -> Double {
        statisticsService.completionPercentage(records: records)
    }

    func weeklyTaskStats(records: [TaskRecord]) -> [TaskStatsPoint] {
        statisticsService.weeklyStats(records: records)
    }

    func monthlyTaskEvolution(records: [TaskRecord]) -> [TaskStatsPoint] {
        statisticsService.monthlyEvolution(records: records)
    }

    // Finanzas
    func totalByCategory(expenses: [Expense]) -> [CategoryExpenseStat] {
        statisticsService.totalByCategory(expenses: expenses)
    }

    func weeklyExpenseTotal(expenses: [Expense]) -> Double {
        statisticsService.weeklyExpenseTotal(expenses: expenses)
    }

    func monthlyExpenseTotal(expenses: [Expense]) -> Double {
        statisticsService.monthlyExpenseTotal(expenses: expenses)
    }
}
