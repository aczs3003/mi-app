import SwiftUI
import SwiftData

struct NoteFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<Task> { $0.isActive }) private var activeTasks: [Task]

    let noteToEdit: Note?

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var linkedTask: Task?
    @State private var errorMessage: String?

    private var viewModel: NoteViewModel { NoteViewModel(context: context) }

    var body: some View {
        NavigationStack {
            Form {
                Section("Nota") {
                    TextField("Título", text: $title)
                    TextField("Contenido", text: $content, axis: .vertical)
                        .lineLimit(5...10)
                }
                Section("Asociar a tarea (opcional)") {
                    Picker("Tarea", selection: $linkedTask) {
                        Text("Ninguna").tag(Task?.none)
                        ForEach(activeTasks) { task in
                            Text(task.name).tag(Task?.some(task))
                        }
                    }
                }
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red).font(.footnote)
                }
            }
            .navigationTitle(noteToEdit == nil ? "Nueva nota" : "Editar nota")
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
        guard let note = noteToEdit else { return }
        title = note.title
        content = note.content
        linkedTask = note.linkedTask
    }

    private func save() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El título es obligatorio."
            return
        }
        if let note = noteToEdit {
            viewModel.updateNote(note, title: title, content: content, linkedTask: linkedTask)
        } else {
            viewModel.createNote(title: title, content: content, linkedTask: linkedTask)
        }
        dismiss()
    }
}
