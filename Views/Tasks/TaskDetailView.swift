import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var task: Task
    @State private var showForm = false

    private var viewModel: TaskViewModel { TaskViewModel(context: context) }

    private var sortedRecords: [TaskRecord] {
        task.records.sorted { $0.occurrenceDate > $1.occurrenceDate }
    }

    var body: some View {
        List {
            Section("Detalle") {
                LabeledContent("Nombre", value: task.name)
                if !task.taskDescription.isEmpty {
                    LabeledContent("Descripción", value: task.taskDescription)
                }
                LabeledContent("Día", value: DateUtilities.weekdayName(task.weekday))
                LabeledContent("Hora", value: String(format: "%02d:%02d", task.hour, task.minute))
                LabeledContent("Estado", value: task.isActive ? "Activa" : "Desactivada")
            }

            Section("Historial (TaskRecord)") {
                if sortedRecords.isEmpty {
                    Text("Aún no hay registros para esta tarea.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedRecords) { record in
                        HStack {
                            Text(record.occurrenceDate, style: .date)
                            Spacer()
                            statusBadge(record.status)
                        }
                    }
                }
            }
        }
        .navigationTitle(task.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Editar") { showForm = true }
            }
            ToolbarItem(placement: .bottomBar) {
                if task.isActive {
                    Button("Desactivar tarea", role: .destructive) { viewModel.deactivate(task) }
                } else {
                    Button("Reactivar tarea") { viewModel.reactivate(task) }
                }
            }
        }
        .sheet(isPresented: $showForm) {
            TaskFormView(taskToEdit: task)
        }
    }

    @ViewBuilder
    private func statusBadge(_ status: TaskRecordStatus) -> some View {
        switch status {
        case .completed:
            Label("Cumplida", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
        case .missed:
            Label("No cumplida", systemImage: "xmark.circle.fill").foregroundStyle(.red)
        case .pending:
            Label("Pendiente", systemImage: "clock").foregroundStyle(.orange)
        }
    }
}
