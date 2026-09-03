import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Finanzas Automatizadas")) {
                    NavigationLink(destination: RecurringExpensesListView()) {
                        Label("Gastos Recurrentes", systemImage: "clock.arrow.circlepath")
                    }
                }
                
                Section(header: Text("Preferencias de App")) {
                    Text("Configuraciones generales (Moneda principal, Tema) se implementarán en la fase de Pulido y Multimoneda.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Configuración")
        }
    }
}
