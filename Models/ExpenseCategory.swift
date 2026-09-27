import Foundation
import SwiftData

enum ExpenseCategoryType: String, Codable, CaseIterable {
    case fixed = "Fijo"
    case variable = "Variable"
    case other = "Otro"
}

@Model
final class ExpenseCategory {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: ExpenseCategoryType

    @Relationship(deleteRule: .nullify, inverse: \Expense.category)
    var expenses: [Expense] = []

    init(id: UUID = UUID(), name: String, type: ExpenseCategoryType = .variable) {
        self.id = id
        self.name = name
        self.type = type
    }
}
