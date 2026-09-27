import SwiftUI
import SwiftData

@main
struct AppPersonalApp: App {
    let container = PersistenceProvider.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .task {
                    _ = await NotificationService.shared.requestAuthorization()
                }
        }
        .modelContainer(container)
    }
}

/// Navegación principal por pestañas: Inicio, Tareas, Finanzas y Notas.
struct RootTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Inicio", systemImage: "house.fill") }

            TaskListView()
                .tabItem { Label("Tareas", systemImage: "checklist") }

            FinanceView()
                .tabItem { Label("Finanzas", systemImage: "dollarsign.circle.fill") }

            NoteListView()
                .tabItem { Label("Notas", systemImage: "note.text") }
        }
    }
}
