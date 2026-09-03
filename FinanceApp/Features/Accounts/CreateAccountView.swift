import SwiftUI
import SwiftData

struct CreateAccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var type: AccountType = .bank
    @State private var currency: String = "COP"
    @State private var initialBalanceString: String = ""
    @State private var errorMessage: String?
    
    // Validación de Fase 12
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !initialBalanceString.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        Form {
            Section(header: Text("Detalles de la Cuenta")) {
                TextField("Nombre (Ej. Bancolombia)", text: $name)
                
                Picker("Tipo", selection: $type) {
                    Text("Banco").tag(AccountType.bank)
                    Text("Efectivo").tag(AccountType.cash)
                    Text("Billetera Digital").tag(AccountType.wallet)
                    Text("Inversión").tag(AccountType.investment)
                    Text("Otro").tag(AccountType.other)
                }
                
                TextField("Moneda (Ej. COP, USD)", text: $currency)
                    .autocapitalization(.allCharacters)
                
                TextField("Saldo Inicial", text: $initialBalanceString)
                    .keyboardType(.decimalPad)
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(AppTheme.errorColor)
                    .font(.footnote)
            }
        }
        .navigationTitle("Nueva Cuenta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") { saveAccount() }
                    .fontWeight(.bold)
                    .disabled(!isFormValid)
            }
        }
    }
    
    private func saveAccount() {
        let service = AccountService(modelContext: modelContext)
        let balance = Double(initialBalanceString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        do {
            try service.createAccount(name: name, type: type, currency: currency, initialBalance: balance)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
