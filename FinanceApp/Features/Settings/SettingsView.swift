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
                    NavigationLink(destination: CurrenciesView()) {
                        Label("Monedas y Tasas de Cambio", systemImage: "dollarsign.arrow.circlepath")
                    }
                }
                
                Section(header: Text("Mantenimiento")) {
                    Text("Copia de Seguridad y Restauración se implementarán en la Fase 11.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Configuración")
        }
    }
}
