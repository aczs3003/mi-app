import SwiftUI
import SwiftData

struct RecurringExpensesView: View {
    @Environment(\.modelContext) private var context
    @Query private var allExpenses: [Expense]
    @Query private var categories: [ExpenseCategory]

    @State private var showForm = false

    private var viewModel: FinanceViewModel { FinanceViewModel(context: context) }

    private var currentYear: Int { DateUtilities.currentYear() }

    private var recurringTemplatesThisYear: [Expense] {
        // Una "plantilla" es representada por el conjunto de gastos recurrentes
        // agrupados por nombre dentro del año, mostramos solo una fila por nombre.
        let filtered = allExpenses.filter { $0.isRecurring && $0.year == currentYear }
        var seen = Set<String>()
        return filtered.filter { seen.insert($0.name).inserted }
    }

    private var needsNewYearSetup: Bool {
        viewModel.needsNewYearSetup(recurringExpenses: allExpenses.filter { $0.isRecurring })
    }

    var body: some View {
        List {
            if needsNewYearSetup {
                Section {
                    Label("Es un nuevo año. Configura tus gastos recurrentes para \(currentYear).", systemImage: "calendar.badge.exclamationmark")
                        .foregroundStyle(.orange)
                }
            }

            Section("Recurrentes de \(currentYear)") {
                if recurringTemplatesThisYear.isEmpty {
                    Text("No hay gastos recurrentes configurados para este año.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(recurringTemplatesThisYear) { expense in
                        VStack(alignment: .leading) {
                            Text(expense.name).font(.headline)
                            Text("Día \(expense.recurringDay ?? 0) · \(CurrencyFormatter.string(from: expense.amount))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if expense.notificationEnabled {
                                Label("Notificación activa", systemImage: "bell.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Gastos recurrentes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showForm = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showForm) {
            RecurringExpenseFormView(year: currentYear)
        }
    }
}

private struct RecurringExpenseFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [ExpenseCategory]

    let year: Int

    @State private var name = ""
    @State private var amountText = ""
    @State private var day = 1
    @State private var category: ExpenseCategory?
    @State private var notificationEnabled = false
    @State private var errorMessage: String?

    private var viewModel: FinanceViewModel { FinanceViewModel(context: context) }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre", text: $name)
                TextField("Valor (COP)", text: $amountText).keyboardType(.numberPad)
                Stepper("Día del mes: \(day)", value: $day, in: 1...28)
                Picker("Categoría", selection: $category) {
                    Text("Sin categoría").tag(ExpenseCategory?.none)
                    ForEach(categories) { cat in
                        Text(cat.name).tag(ExpenseCategory?.some(cat))
                    }
                }
                Toggle("Notificarme", isOn: $notificationEnabled)
                Text("Se generará para el año \(year) y finalizará automáticamente el 31 de diciembre.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red).font(.footnote)
                }
            }
            .navigationTitle("Gasto recurrente")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guard let amount = Double(amountText), amount > 0 else {
                            errorMessage = "Ingresa un valor válido."
                            return
                        }
                        viewModel.createRecurringExpense(
                            name: name, amount: amount, day: day, year: year,
                            category: category, notificationEnabled: notificationEnabled
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}
