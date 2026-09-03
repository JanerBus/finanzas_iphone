import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<RecurringExpense> { $0.isActive }) private var allRecurring: [RecurringExpense]
    
    // Gastos que ya cumplieron o se pasaron de su fecha
    var pendingRecurring: [RecurringExpense] {
        let now = Date()
        return allRecurring.filter { $0.nextOccurrence <= now }.sorted(by: { $0.nextOccurrence < $1.nextOccurrence })
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !pendingRecurring.isEmpty {
                    Section(header: Text("Gastos Recurrentes Pendientes")) {
                        ForEach(pendingRecurring) { expense in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(expense.name).font(.headline)
                                    Spacer()
                                    Text("\(expense.amount, specifier: "%.2f") \(expense.currency)")
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.errorColor)
                                }
                                Text("Programado para: \(expense.nextOccurrence, style: .date)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Button("Omitir") { skip(expense) }
                                    .buttonStyle(.bordered)
                                    .tint(.secondary)
                                    
                                    Spacer()
                                    
                                    Button("Registrar Gasto") { record(expense) }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
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
    
    private func skip(_ expense: RecurringExpense) {
        let service = RecurringExpenseService(modelContext: modelContext)
        try? service.skipOccurrence(expense)
    }
    
    private func record(_ expense: RecurringExpense) {
        let service = RecurringExpenseService(modelContext: modelContext)
        do {
            try service.recordOccurrence(expense: expense)
        } catch {
            print("Error al registrar recurrente: \(error)")
        }
    }
}
