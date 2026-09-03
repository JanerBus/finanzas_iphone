import SwiftUI
import SwiftData

struct RecordCardPurchaseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let card: CreditCard
    
    @State private var merchant = ""
    @State private var amountString = ""
    @State private var installments = 1
    @State private var date = Date()
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            Section(header: Text("Detalles de Compra")) {
                TextField("Comercio (ej. Apple, Éxito)", text: $merchant)
                TextField("Valor Total", text: $amountString).keyboardType(.decimalPad)
                Stepper("Cuotas: \(installments)", value: $installments, in: 1...72)
                DatePicker("Fecha", selection: $date, displayedComponents: .date)
            }
            if let error = errorMessage {
                Text(error).foregroundColor(AppTheme.errorColor).font(.footnote)
            }
        }
        .navigationTitle("Nueva Compra")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { Button("Cancelar") { dismiss() } }
            ToolbarItem(placement: .navigationBarTrailing) { Button("Guardar") { save() }.fontWeight(.bold) }
        }
    }
    
    private func save() {
        let service = CreditCardService(modelContext: modelContext)
        let amount = Double(amountString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        do {
            try service.recordPurchase(card: card, amount: amount, merchant: merchant, date: date, installmentsCount: installments, category: nil)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct RecordCardPaymentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let card: CreditCard
    @Query(filter: #Predicate<Account> { $0.isActive }) private var accounts: [Account]
    
    @State private var amountString = ""
    @State private var selectedAccount: Account?
    @State private var date = Date()
    @State private var errorMessage: String?
    
    var body: some View {
        let service = CreditCardService(modelContext: modelContext)
        let utilized = service.calculateUtilizedBalance(for: card)
        
        Form {
            Section(header: Text("Pago de Tarjeta"), footer: Text("Deuda Total: \(utilized, specifier: "%.2f")")) {
                TextField("Monto a pagar", text: $amountString).keyboardType(.decimalPad)
                
                Picker("Desde la cuenta", selection: $selectedAccount) {
                    Text("Seleccione").tag(nil as Account?)
                    ForEach(accounts) { account in
                        Text(account.name).tag(account as Account?)
                    }
                }
                
                DatePicker("Fecha", selection: $date, displayedComponents: .date)
            }
            if let error = errorMessage {
                Text(error).foregroundColor(AppTheme.errorColor).font(.footnote)
            }
        }
        .navigationTitle("Pagar Tarjeta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { Button("Cancelar") { dismiss() } }
            ToolbarItem(placement: .navigationBarTrailing) { Button("Confirmar") { save() }.fontWeight(.bold) }
        }
    }
    
    private func save() {
        let service = CreditCardService(modelContext: modelContext)
        let amount = Double(amountString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        guard let account = selectedAccount else {
            errorMessage = "Selecciona una cuenta."
            return
        }
        do {
            try service.recordPayment(card: card, amount: amount, account: account, date: date)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
