import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ExpenseCategory.name) private var categories: [ExpenseCategory]

    @State private var newCategoryName = ""
    @State private var newCategoryType: ExpenseCategoryType = .variable

    private var viewModel: FinanceViewModel { FinanceViewModel(context: context) }

    var body: some View {
        List {
            Section("Nueva categoría") {
                TextField("Nombre", text: $newCategoryName)
                Picker("Tipo", selection: $newCategoryType) {
                    ForEach(ExpenseCategoryType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                Button("Agregar") {
                    viewModel.createCategory(name: newCategoryName, type: newCategoryType)
                    newCategoryName = ""
                }
                .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            Section("Categorías") {
                if categories.isEmpty {
                    Text("Aún no hay categorías.").foregroundStyle(.secondary)
                } else {
                    ForEach(categories) { category in
                        HStack {
                            Text(category.name)
                            Spacer()
                            Text(category.type.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(category.expenses.reduce(0) { $0 + $1.amount }, format: .currency(code: Constants.currencyCode))")
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .navigationTitle("Categorías")
    }
}
