import Foundation

enum CurrencyFormatter {
    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: Constants.localeIdentifier)
        f.currencyCode = Constants.currencyCode
        f.maximumFractionDigits = 0
        return f
    }()

    static func string(from amount: Double) -> String {
        formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}
