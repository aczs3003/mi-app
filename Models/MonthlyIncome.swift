import Foundation
import SwiftData

@Model
final class MonthlyIncome {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var month: Int   // 1-12
    var year: Int

    init(id: UUID = UUID(), amount: Double, month: Int, year: Int) {
        self.id = id
        self.amount = amount
        self.month = month
        self.year = year
    }
}
