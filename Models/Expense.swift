import Foundation
import SwiftData

@Model
final class Expense {
    @Attribute(.unique) var id: UUID
    var name: String
    var amount: Double
    var date: Date
    var isRecurring: Bool
    var recurringDay: Int?      // día del mes (1-31), solo si isRecurring
    var year: Int?              // año al que pertenece la recurrencia
    var notificationEnabled: Bool

    var category: ExpenseCategory?

    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        date: Date = .now,
        category: ExpenseCategory? = nil,
        isRecurring: Bool = false,
        recurringDay: Int? = nil,
        year: Int? = nil,
        notificationEnabled: Bool = false
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.date = date
        self.category = category
        self.isRecurring = isRecurring
        self.recurringDay = recurringDay
        self.year = year
        self.notificationEnabled = notificationEnabled
    }
}
