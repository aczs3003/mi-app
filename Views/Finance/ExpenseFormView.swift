import SwiftUI
import SwiftData

struct ExpenseFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [ExpenseCategory]

    var expenseToEdit: Expense?

    @State private var name: String = ""
    @State private var amountText: String = ""
    @State private var date: Date = .now
    @State private var category: ExpenseCategory?
    @State private var errorMessage: String?

    private var viewModel: FinanceViewModel { FinanceViewModel(context: context) }

    var body: some View {
        NavigationStack {
            Form {
                Section("Gasto") {
                    TextField("Nombre", text: $name)
                    TextField("Valor (COP)", text: $amountText)
                        .keyboardType(.numberPad)
                    DatePicker("Fecha", selection: $date, displayedComponents: .date)
                    Picker("Categoría", selection: $category) {
                        Text("Sin categoría").tag(ExpenseCategory?.none)
                        ForEach(categories) { cat in
                            Text(cat.name).tag(ExpenseCategory?.some(cat))
                        }
                    }
                }
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red).font(.footnote)
                }
            }
            .navigationTitle(expenseToEdit == nil ? "Nuevo gasto" : "Editar gasto")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                }
            }
            .onAppear(perform: loadIfEditing)
        }
    }

    private func loadIfEditing() {
        guard let expense = expenseToEdit else { return }
        name = expense.name
        amountText = String(format: "%.0f", expense.amount)
        date = expense.date
        category = expense.category
    }

    private func save() {
        guard let amount = Double(amountText), amount > 0 else {
            errorMessage = "Ingresa un valor válido."
            return
        }
        if let expense = expenseToEdit {
            viewModel.updateExpense(expense, name: name, amount: amount, date: date, category: category)
        } else {
            viewModel.createExpense(name: name, amount: amount, date: date, category: category)
        }
        dismiss()
    }
}
