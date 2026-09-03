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
                    NavigationLink(destination: BackupView()) {
                        Label("Copia de Seguridad (Backup JSON)", systemImage: "externaldrive.fill")
                    }
                }
            }
            .navigationTitle("Configuración")
        }
    }
}
