import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var note: Note
    @State private var showForm = false

    private var viewModel: NoteViewModel { NoteViewModel(context: context) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(note.title).font(.title2).bold()
                Text("Creada: \(note.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption).foregroundStyle(.secondary)
                Text("Modificada: \(note.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption).foregroundStyle(.secondary)
                if let linked = note.linkedTask {
                    Label("Asociada a: \(linked.name)", systemImage: "link")
                        .font(.footnote)
                        .foregroundStyle(.blue)
                }
                Divider()
                Text(note.content)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Nota")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Editar") { showForm = true }
            }
        }
        .sheet(isPresented: $showForm) {
            NoteFormView(noteToEdit: note)
        }
    }
}
