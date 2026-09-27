import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query private var tasks: [Task]
    @Query private var expenses: [Expense]
    @Query private var incomes: [MonthlyIncome]

    private let viewModel = DashboardViewModel()
    private var taskViewModel: TaskViewModel { TaskViewModel(context: context) }
    private var financeViewModel: FinanceViewModel { FinanceViewModel(context: context) }

    private var currentIncome: Double {
        incomes.first { $0.month == DateUtilities.currentMonth() && $0.year == DateUtilities.currentYear() }?.amount ?? 0
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(Date.now, style: .date)
                        .font(.title3.bold())
                }

                Section("Tareas de hoy") {
                    let today = viewModel.todaysTasks(tasks)
                    if today.isEmpty {
                        Text("No tienes tareas programadas para hoy.")
                            .foregroundStyle(.secondary)
                    } else {
                        HStack {
                            Label("\(viewModel.pendingCount(tasks)) pendientes", systemImage: "clock")
                            Spacer()
                            Label("\(viewModel.completedCount(tasks)) cumplidas", systemImage: "checkmark.circle")
                        }
                        .font(.subheadline)

                        ForEach(today) { task in
                            HStack {
                                Text(task.name)
                                Spacer()
                                Text(String(format: "%02d:%02d", task.hour, task.minute))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Finanzas") {
                    LabeledContent("Disponible") {
                        Text(CurrencyFormatter.string(from: financeViewModel.availableBalance(income: currentIncome, expenses: expenses)))
                            .bold()
                    }
                    let recent = viewModel.recentExpenses(expenses)
                    if !recent.isEmpty {
                        ForEach(recent) { expense in
                            HStack {
                                Text(expense.name)
                                Spacer()
                                Text(CurrencyFormatter.string(from: expense.amount))
                                    .font(.caption)
                            }
                        }
                    }
                }

                let upcoming = viewModel.upcomingRecurringExpenses(expenses)
                if !upcoming.isEmpty {
                    Section("Próximos gastos programados") {
                        ForEach(upcoming) { expense in
                            HStack {
                                Text(expense.name)
                                Spacer()
                                Text(expense.date, style: .date).font(.caption)
                            }
                        }
                    }
                }

                Section("Accesos") {
                    NavigationLink("Estadísticas de tareas") { TaskStatisticsView() }
                    NavigationLink("Estadísticas financieras") { FinanceStatisticsView() }
                }
            }
            .navigationTitle("Inicio")
            .task {
                taskViewModel.closeOverdueRecords(tasks: tasks)
            }
        }
    }
}
