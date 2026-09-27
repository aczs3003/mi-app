import Foundation
import SwiftData

enum PersistenceProvider {
    /// Contenedor único de la app. Persistencia 100% local (sin CloudKit).
    static func makeContainer() -> ModelContainer {
        let schema = Schema([
            Task.self,
            TaskRecord.self,
            Note.self,
            Expense.self,
            ExpenseCategory.self,
            MonthlyIncome.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("No fue posible crear el ModelContainer: \(error)")
        }
    }
}
