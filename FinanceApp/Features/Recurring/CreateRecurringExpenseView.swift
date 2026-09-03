import SwiftUI
import SwiftData

struct CreateRecurringExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(filter: #Predicate<Account> { $0.isActive }) private var accounts: [Account]
    
    @State private var name: String = ""
    @State private var amountString: String = ""
    @State private var frequency: Frequency = .monthly
    @State private var nextDate: Date = Date()
    @State private var selectedAccount: Account?
    
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            Section(header: Text("Detalles del Gasto")) {
                TextField("Nombre (ej. Netflix, Arriendo)", text: $name)
                TextField("Monto a descontar", text: $amountString)
                    .keyboardType(.decimalPad)
                
                Picker("Frecuencia", selection: $frequency) {
                    Text("Diario").tag(Frequency.daily)
                    Text("Semanal").tag(Frequency.weekly)
                    Text("Quincenal").tag(Frequency.biweekly)
                    Text("Mensual").tag(Frequency.monthly)
                    Text("Anual").tag(Frequency.yearly)
                }
            }
            
            Section(header: Text("Cobro y Fecha")) {
                Picker("Cuenta de donde sale el dinero", selection: $selectedAccount) {
                    Text("Seleccione").tag(nil as Account?)
                    ForEach(accounts) { account in
                        Text(account.name).tag(account as Account?)
                    }
                }
                
                DatePicker("Próximo Cobro", selection: $nextDate, displayedComponents: .date)
            }
            
            if let error = errorMessage {
                Text(error).foregroundColor(AppTheme.errorColor).font(.footnote)
            }
        }
        .navigationTitle("Nuevo Recurrente")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { Button("Cancelar") { dismiss() } }
            ToolbarItem(placement: .navigationBarTrailing) { Button("Guardar") { save() }.fontWeight(.bold) }
        }
    }
    
    private func save() {
        let service = RecurringExpenseService(modelContext: modelContext)
        let amount = Double(amountString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        do {
            try service.createRecurringExpense(name: name, amount: amount, currency: selectedAccount?.currency ?? "COP", frequency: frequency, firstOccurrence: nextDate, account: selectedAccount)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
