import Foundation

enum DateUtilities {
    static var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 2 // semana inicia lunes
        return cal
    }

    static func currentYear(_ date: Date = .now) -> Int {
        calendar.component(.year, from: date)
    }

    static func currentMonth(_ date: Date = .now) -> Int {
        calendar.component(.month, from: date)
    }

    static func weekday(of date: Date) -> Int {
        calendar.component(.weekday, from: date) // 1 = domingo ... 7 = sábado
    }

    /// Inicio (lunes) de la semana que contiene `date`.
    static func startOfWeek(for date: Date = .now) -> Date {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: comps) ?? date
    }

    static func endOfWeek(for date: Date = .now) -> Date {
        calendar.date(byAdding: .day, value: 6, to: startOfWeek(for: date)) ?? date
    }

    static func startOfMonth(for date: Date = .now) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

    static func endOfMonth(for date: Date = .now) -> Date {
        guard let start = calendar.date(byAdding: .month, value: 1, to: startOfMonth(for: date)) else { return date }
        return calendar.date(byAdding: .day, value: -1, to: start) ?? date
    }

    static func isSameDay(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, inSameDayAs: b)
    }

    /// Próxima fecha (a partir de `from`) en la que ocurre el `weekday`/`hour`/`minute` dados.
    static func nextOccurrence(weekday: Int, hour: Int, minute: Int, from: Date = .now) -> Date? {
        var comps = DateComponents()
        comps.weekday = weekday
        comps.hour = hour
        comps.minute = minute
        return calendar.nextDate(after: from, matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents)
    }

    static func weekdayName(_ weekday: Int) -> String {
        let symbols = calendar.weekdaySymbols // domingo..sábado (índice 0 = domingo)
        guard weekday >= 1 && weekday <= 7 else { return "" }
        return symbols[weekday - 1].capitalized
    }

    static func date(year: Int, month: Int, day: Int) -> Date? {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return calendar.date(from: comps)
    }
}
