import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Note.updatedAt, order: .reverse) private var notes: [Note]
    @State private var showForm = false

    private var viewModel: NoteViewModel { NoteViewModel(context: context) }

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    ContentUnavailableView(
                        "Sin notas",
                        systemImage: "note.text",
                        description: Text("Crea tu primera nota con el botón +.")
                    )
                } else {
                    List {
                        ForEach(notes) { note in
                            NavigationLink(value: note) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(note.title).font(.headline)
                                    Text(note.updatedAt, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    if let linked = note.linkedTask {
                                        Label(linked.name, systemImage: "link")
                                            .font(.caption2)
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteNotes)
                    }
                }
            }
            .navigationTitle("Notas")
            .navigationDestination(for: Note.self) { note in
                NoteDetailView(note: note)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showForm = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showForm) {
                NoteFormView(noteToEdit: nil)
            }
        }
    }

    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteNote(notes[index])
        }
    }
}
