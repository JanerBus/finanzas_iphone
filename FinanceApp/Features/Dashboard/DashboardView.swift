import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Accesos Rápidos")) {
                    NavigationLink(destination: AccountsListView()) {
                        HStack {
                            Image(systemName: "building.columns.fill")
                                .foregroundColor(AppTheme.primaryColor)
                            Text("Mis Cuentas")
                        }
                    }
                }
                
                Section(header: Text("Resumen de Patrimonio")) {
                    Text("Los gráficos y saldos totales se implementarán en la Fase 8.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Inicio")
        }
    }
}
