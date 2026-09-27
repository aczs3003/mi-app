import SwiftUI
import SwiftData

struct TaskFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let taskToEdit: Task?

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var weekday: Int = DateUtilities.weekday(of: .now)
    @State private var time: Date = .now
    @State private var errorMessage: String?

    private var viewModel: TaskViewModel { TaskViewModel(context: context) }

    private let weekdays = Array(1...7)

    var body: some View {
        NavigationStack {
            Form {
                Section("Datos de la tarea") {
                    TextField("Nombre", text: $name)
                    TextField("Descripción (opcional)", text: $description, axis: .vertical)
                }
                Section("Programación") {
                    Picker("Día de la semana", selection: $weekday) {
                        ForEach(weekdays, id: \.self) { day in
                            Text(DateUtilities.weekdayName(day)).tag(day)
                        }
                    }
                    DatePicker("Hora", selection: $time, displayedComponents: .hourAndMinute)
                }
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red).font(.footnote)
                }
            }
            .navigationTitle(taskToEdit == nil ? "Nueva tarea" : "Editar tarea")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                }
            }
            .onAppear(perform: loadIfEditing)
        }
    }

    private func loadIfEditing() {
        guard let task = taskToEdit else { return }
        name = task.name
        description = task.taskDescription
        weekday = task.weekday
        time = DateUtilities.calendar.date(bySettingHour: task.hour, minute: task.minute, second: 0, of: .now) ?? .now
    }

    private func save() {
        let hour = DateUtilities.calendar.component(.hour, from: time)
        let minute = DateUtilities.calendar.component(.minute, from: time)

        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El nombre es obligatorio."
            return
        }

        if let task = taskToEdit {
            viewModel.updateTask(task, name: name, description: description, weekday: weekday, hour: hour, minute: minute)
        } else {
            viewModel.createTask(name: name, description: description, weekday: weekday, hour: hour, minute: minute)
        }
        dismiss()
    }
}
