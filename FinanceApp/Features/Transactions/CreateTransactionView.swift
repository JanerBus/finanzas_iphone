import SwiftUI
import SwiftData

struct CreateTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(filter: #Predicate<Account> { $0.isActive }, sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Category.name) private var categories: [Category]
    
    @State private var transactionType: TransactionType = .expense
    @State private var amountString: String = ""
    @State private var desc: String = ""
    @State private var date: Date = Date()
    
    @State private var selectedAccount: Account?
    @State private var destinationAccount: Account? 
    @State private var selectedCategory: Category?
    
    @State private var errorMessage: String?
    
    // Validación Fase 12
    var isFormValid: Bool {
        if transactionType == .transfer {
            return !amountString.trimmingCharacters(in: .whitespaces).isEmpty && selectedAccount != nil && destinationAccount != nil && selectedAccount != destinationAccount
        } else {
            return !amountString.trimmingCharacters(in: .whitespaces).isEmpty && !desc.trimmingCharacters(in: .whitespaces).isEmpty && selectedAccount != nil
        }
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Tipo", selection: $transactionType) {
                    Text("Gasto").tag(TransactionType.expense)
                    Text("Ingreso").tag(TransactionType.income)
                    Text("Transferencia").tag(TransactionType.transfer)
                }
                .pickerStyle(.segmented)
            }
            
            Section(header: Text("Detalles")) {
                TextField("Monto", text: $amountString)
                    .keyboardType(.decimalPad)
                
                TextField("Descripción (Ej. Restaurante)", text: $desc)
                
                DatePicker("Fecha", selection: $date, displayedComponents: [.date, .hourAndMinute])
                
                if transactionType != .transfer {
                    Picker("Categoría", selection: $selectedCategory) {
                        Text("Ninguna").tag(nil as Category?)
                        ForEach(categories) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                }
            }
            
            Section(header: Text(transactionType == .transfer ? "Cuenta Origen" : "Cuenta")) {
                if accounts.isEmpty {
                    Text("Debes crear al menos una cuenta primero.")
                        .foregroundColor(AppTheme.errorColor)
                        .font(.footnote)
                } else {
                    Picker("Seleccione", selection: $selectedAccount) {
                        Text("Ninguna").tag(nil as Account?)
                        ForEach(accounts) { account in
                            Text(account.name).tag(account as Account?)
                        }
                    }
                }
            }
            
            if transactionType == .transfer && !accounts.isEmpty {
                Section(header: Text("Cuenta Destino")) {
                    Picker("Seleccione", selection: $destinationAccount) {
                        Text("Ninguna").tag(nil as Account?)
                        ForEach(accounts) { account in
                            Text(account.name).tag(account as Account?)
                        }
                    }
                }
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(AppTheme.errorColor)
                    .font(.footnote)
            }
        }
        .navigationTitle("Nuevo Movimiento")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancelar") { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") { saveTransaction() }
                    .fontWeight(.bold)
                    .disabled(!isFormValid || accounts.isEmpty)
            }
        }
        .onAppear {
            if selectedAccount == nil { selectedAccount = accounts.first }
        }
    }
    
    private func saveTransaction() {
        let service = TransactionService(modelContext: modelContext)
        let amount = Double(amountString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        guard let account = selectedAccount else {
            errorMessage = "Debes seleccionar una cuenta."
            return
        }
        
        do {
            switch transactionType {
            case .expense:
                try service.recordExpense(amount: amount, currency: account.currency, date: date, desc: desc, category: selectedCategory, account: account)
            case .income:
                try service.recordIncome(amount: amount, currency: account.currency, date: date, desc: desc, category: selectedCategory, account: account)
            case .transfer:
                guard let destAccount = destinationAccount else {
                    errorMessage = "Falta cuenta destino."
                    return
                }
                try service.recordTransfer(amount: amount, currency: account.currency, date: date, desc: desc, fromAccount: account, toAccount: destAccount)
            default:
                break
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
