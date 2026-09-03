import SwiftUI

struct CreateAccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var selectedType: AccountType = .bank
    @State private var currency: String = "COP"
    @State private var initialBalanceString: String = ""
    @State private var notes: String = ""
    
    @State private var errorMessage: String? = nil
    
    var body: some View {
        Form {
            Section(header: Text("Detalles Principales")) {
                TextField("Nombre (ej. Efectivo, Nequi)", text: $name)
                
                Picker("Tipo de cuenta", selection: $selectedType) {
                    Text("Efectivo").tag(AccountType.cash)
                    Text("Banco").tag(AccountType.bank)
                    Text("Billetera Digital").tag(AccountType.digitalWallet)
                    Text("Ahorros").tag(AccountType.savings)
                    Text("Otro").tag(AccountType.other)
                }
                
                TextField("Moneda (ej. COP, USD)", text: $currency)
                    .autocapitalization(.allCharacters)
            }
            
            Section(header: Text("Balance Inicial"), footer: Text("Monto real que ya posees en esta cuenta actualmente.")) {
                TextField("Monto", text: $initialBalanceString)
                    .keyboardType(.decimalPad)
            }
            
            Section(header: Text("Opcional")) {
                TextField("Notas", text: $notes)
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
            }
        }
    }
    
    private func saveAccount() {
        let service = AccountService(modelContext: modelContext)
        let balance = Double(initialBalanceString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        do {
            try service.createAccount(
                name: name,
                type: selectedType,
                currency: currency,
                initialBalance: balance,
                notes: notes.isEmpty ? nil : notes
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
