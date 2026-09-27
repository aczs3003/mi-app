import SwiftUI
import SwiftData

struct FinanceView: View {
    @Environment(\.modelContext) private var context
    @Query private var expenses: [Expense]
    @Query private var incomes: [MonthlyIncome]

    @State private var showExpenseForm = false
    @State private var showIncomeSheet = false
    @State private var incomeInput: String = ""

    private var viewModel: FinanceViewModel { FinanceViewModel(context: context) }

    private var currentIncome: MonthlyIncome? {
        incomes.first { $0.month == DateUtilities.currentMonth() && $0.year == DateUtilities.currentYear() }
    }

    private var thisMonthExpenses: [Expense] {
        let start = DateUtilities.startOfMonth()
        let end = DateUtilities.endOfMonth()
        return expenses.filter { $0.date >= start && $0.date <= end }.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Resumen del mes") {
                    LabeledContent("Sueldo") {
                        Text(CurrencyFormatter.string(from: currentIncome?.amount ?? 0))
                    }
                    LabeledContent("Gastado") {
                        Text(CurrencyFormatter.string(from: thisMonthExpenses.reduce(0) { $0 + $1.amount }))
                    }
                    LabeledContent("Disponible") {
                        Text(CurrencyFormatter.string(from: viewModel.availableBalance(income: currentIncome?.amount ?? 0, expenses: expenses)))
                            .bold()
                    }
                    Button("Registrar / actualizar sueldo") { showIncomeSheet = true }
                }

                Section("Gastos de este mes") {
                    if thisMonthExpenses.isEmpty {
                        Text("Aún no hay gastos registrados este mes.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(thisMonthExpenses) { expense in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(expense.name)
                                    Text(expense.category?.name ?? "Sin categoría")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(CurrencyFormatter.string(from: expense.amount))
                            }
                        }
                        .onDelete(perform: deleteExpenses)
                    }
                }

                Section("Gestión") {
                    NavigationLink("Categorías") { CategoriesView() }
                    NavigationLink("Gastos recurrentes") { RecurringExpensesView() }
                    NavigationLink("Estadísticas financieras") { FinanceStatisticsView() }
                }
            }
            .navigationTitle("Finanzas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showExpenseForm = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showExpenseForm) {
                ExpenseFormView()
            }
            .sheet(isPresented: $showIncomeSheet) {
                incomeSheet
            }
        }
    }

    private var incomeSheet: some View {
        NavigationStack {
            Form {
                TextField("Sueldo mensual (COP)", text: $incomeInput)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Sueldo mensual")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { showIncomeSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        if let amount = Double(incomeInput) {
                            viewModel.setMonthlyIncome(
                                amount: amount,
                                month: DateUtilities.currentMonth(),
                                year: DateUtilities.currentYear(),
                                existingIncome: currentIncome
                            )
                        }
                        showIncomeSheet = false
                    }
                }
            }
            .onAppear { incomeInput = currentIncome.map { String(format: "%.0f", $0.amount) } ?? "" }
        }
    }

    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteExpense(thisMonthExpenses[index])
        }
    }
}
