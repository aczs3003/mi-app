import SwiftUI
import SwiftData
import Charts

struct TaskStatisticsView: View {
    @Query private var records: [TaskRecord]
    private let viewModel = StatisticsViewModel()

    private var weeklyStats: [TaskStatsPoint] { viewModel.weeklyTaskStats(records: records) }
    private var monthlyStats: [TaskStatsPoint] { viewModel.monthlyTaskEvolution(records: records) }
    private var percentage: Double { viewModel.completionPercentage(records: records) }

    var body: some View {
        List {
            Section("Porcentaje de cumplimiento") {
                Gauge(value: percentage, in: 0...100) {
                    Text("Cumplimiento")
                } currentValueLabel: {
                    Text("\(Int(percentage))%")
                }
                .gaugeStyle(.accessoryLinear)
            }

            Section("Semana actual") {
                Chart(weeklyStats) { point in
                    BarMark(x: .value("Día", point.label), y: .value("Cumplidas", point.completed))
                        .foregroundStyle(.green)
                    BarMark(x: .value("Día", point.label), y: .value("No cumplidas", point.missed))
                        .foregroundStyle(.red)
                }
                .frame(height: 220)
            }

            Section("Evolución mensual") {
                Chart(monthlyStats) { point in
                    LineMark(x: .value("Mes", point.label), y: .value("Cumplidas", point.completed))
                        .foregroundStyle(.green)
                    LineMark(x: .value("Mes", point.label), y: .value("No cumplidas", point.missed))
                        .foregroundStyle(.red)
                }
                .frame(height: 220)
            }
        }
        .navigationTitle("Estadísticas de tareas")
    }
}
