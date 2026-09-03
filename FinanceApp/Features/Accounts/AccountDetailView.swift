import SwiftUI
import SwiftData

struct AccountDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var account: Account // Permite editar propiedades directamente con @Bindable
    
    var body: some View {
        List {
            Section(header: Text("Información General")) {
                HStack {
                    Text("Nombre")
                    Spacer()
                    TextField("Nombre", text: $account.name)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Moneda")
                    Spacer()
                    Text(account.currency)
                        .foregroundColor(.secondary)
                }
                
                let balance = account.initialBalance + account.ledgerEntries.reduce(0) { $0 + $1.amount }
                HStack {
                    Text("Saldo Actual")
                    Spacer()
                    Text("\(balance, specifier: "%.2f")")
                        .fontWeight(.bold)
                        .foregroundColor(balance >= 0 ? .primary : AppTheme.errorColor)
                }
            }
            
            Section(header: Text("Administración")) {
                Button(action: toggleStatus) {
                    Text(account.isActive ? "Desactivar Cuenta" : "Activar Cuenta")
                        .foregroundColor(account.isActive ? AppTheme.errorColor : AppTheme.successColor)
                }
            }
            
            Section(header: Text("Historial de Impactos (Ledger)"), footer: Text("Entradas reales que afectan este saldo.")) {
                if account.ledgerEntries.isEmpty {
                    Text("No hay movimientos registrados.")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                } else {
                    // Muestra los registros más recientes primero
                    ForEach(account.ledgerEntries.sorted(by: { $0.createdAt > $1.createdAt })) { entry in
                        HStack {
                            Text(entry.createdAt, style: .date)
                            Spacer()
                            Text("\(entry.amount > 0 ? "+" : "")\(entry.amount, specifier: "%.2f")")
                                .foregroundColor(entry.amount >= 0 ? AppTheme.successColor : .primary)
                        }
                    }
                }
            }
        }
        .navigationTitle(account.name)
    }
    
    private func toggleStatus() {
        let service = AccountService(modelContext: modelContext)
        do {
            try service.toggleAccountActiveStatus(account: account)
        } catch {
            print("Error toggling status: \(error)")
        }
    }
}
