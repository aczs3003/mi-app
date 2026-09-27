import SwiftUI
import SwiftData
import Charts

struct FinanceStatisticsView: View {
    @Query private var expenses: [Expense]
    private let viewModel = StatisticsViewModel()

    private var byCategory: [CategoryExpenseStat] { viewModel.totalByCategory(expenses: expenses) }

    var body: some View {
        List {
            Section("Resumen") {
                LabeledContent("Gasto semanal") {
                    Text(CurrencyFormatter.string(from: viewModel.weeklyExpenseTotal(expenses: expenses)))
                }
                LabeledContent("Gasto mensual") {
                    Text(CurrencyFormatter.string(from: viewModel.monthlyExpenseTotal(expenses: expenses)))
                }
            }

            Section("Por categoría") {
                Chart(byCategory) { stat in
                    BarMark(x: .value("Categoría", stat.categoryName), y: .value("Total", stat.total))
                }
                .frame(height: 240)

                ForEach(byCategory) { stat in
                    HStack {
                        Text(stat.categoryName)
                        Spacer()
                        Text(CurrencyFormatter.string(from: stat.total))
                    }
                }
            }
        }
        .navigationTitle("Estadísticas financieras")
    }
}
