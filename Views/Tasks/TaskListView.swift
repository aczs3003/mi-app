import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Task.name) private var tasks: [Task]
    @State private var showForm = false
    @State private var taskToEdit: Task?
    @State private var showInactive = false

    private var viewModel: TaskViewModel { TaskViewModel(context: context) }

    private var filteredTasks: [Task] {
        tasks.filter { $0.isActive != showInactive ? false : true }
            .filter { showInactive ? !$0.isActive : $0.isActive }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredTasks.isEmpty {
                    ContentUnavailableView(
                        showInactive ? "Sin tareas desactivadas" : "Sin tareas activas",
                        systemImage: "checklist",
                        description: Text(showInactive ? "Las tareas que desactives aparecerán aquí." : "Crea tu primera tarea con el botón +.")
                    )
                } else {
                    List {
                        ForEach(filteredTasks) { task in
                            NavigationLink(value: task) {
                                TaskRow(task: task, viewModel: viewModel)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tareas")
            .navigationDestination(for: Task.self) { task in
                TaskDetailView(task: task)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showForm = true } label: { Image(systemName: "plus") }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Toggle("Ver desactivadas", isOn: $showInactive)
                        .toggleStyle(.button)
                }
            }
            .sheet(isPresented: $showForm) {
                TaskFormView(taskToEdit: nil)
            }
        }
    }
}

private struct TaskRow: View {
    let task: Task
    let viewModel: TaskViewModel

    private var todayStatus: TaskRecordStatus? {
        task.records.first { DateUtilities.isSameDay($0.occurrenceDate, .now) }?.status
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name).font(.headline)
                Text("\(DateUtilities.weekdayName(task.weekday)) · \(String(format: "%02d:%02d", task.hour, task.minute))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if task.isActive {
                Button {
                    viewModel.markCompleted(task)
                } label: {
                    Image(systemName: todayStatus == .completed ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(todayStatus == .completed ? .green : .secondary)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            } else {
                Text("Inactiva").font(.caption).foregroundStyle(.secondary)
            }
        }
        .swipeActions {
            if task.isActive {
                Button("Desactivar", role: .destructive) { viewModel.deactivate(task) }
            } else {
                Button("Reactivar") { viewModel.reactivate(task) }
            }
        }
    }
}
