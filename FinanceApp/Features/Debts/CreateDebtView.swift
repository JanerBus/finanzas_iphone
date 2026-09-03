import SwiftUI
import SwiftData

struct CreateDebtView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Person.name) private var persons: [Person]
    @Query(filter: #Predicate<Account> { $0.isActive }, sort: \Account.name) private var accounts: [Account]
    
    @State private var type: DebtDirection = .receivable
    @State private var amountString: String = ""
    @State private var desc: String = ""
    @State private var date: Date = Date()
    
    @State private var selectedPerson: Person?
    @State private var selectedAccount: Account?
    
    @State private var showingCreatePerson = false
    @State private var newPersonName = ""
    
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            Section(header: Text("Tipo de Operación")) {
                Picker("Tipo", selection: $type) {
                    Text("Prestar dinero (Me deben)").tag(DebtDirection.receivable)
                    Text("Recibir préstamo (Yo debo)").tag(DebtDirection.payable)
                }
                .pickerStyle(.menu)
            }
            
            Section(header: Text("Persona"), footer: Text("¿A quién le prestas o quién te presta?")) {
                HStack {
                    Picker("Seleccionar", selection: $selectedPerson) {
                        Text("Ninguna").tag(nil as Person?)
                        ForEach(persons) { person in
                            Text(person.name).tag(person as Person?)
                        }
                    }
                    Button(action: { showingCreatePerson = true }) {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            
            Section(header: Text("Detalles Financieros")) {
                TextField("Monto", text: $amountString)
                    .keyboardType(.decimalPad)
                
                Picker("Cuenta afectada", selection: $selectedAccount) {
                    Text("Seleccione").tag(nil as Account?)
                    ForEach(accounts) { account in
                        Text(account.name).tag(account as Account?)
                    }
                }
                
                TextField("Descripción breve", text: $desc)
                DatePicker("Fecha", selection: $date, displayedComponents: .date)
            }
            
            if let error = errorMessage {
                Text(error).foregroundColor(AppTheme.errorColor).font(.footnote)
            }
        }
        .navigationTitle("Registrar Préstamo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Guardar") { saveDebt() }
                    .fontWeight(.bold)
            }
        }
        .alert("Nueva Persona", isPresented: $showingCreatePerson) {
            TextField("Nombre", text: $newPersonName)
            Button("Cancelar", role: .cancel) { newPersonName = "" }
            Button("Crear") { createPerson() }
        }
    }
    
    private func createPerson() {
        let service = DebtService(modelContext: modelContext)
        do {
            try service.createPerson(name: newPersonName, phone: nil, email: nil, notes: nil)
            newPersonName = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func saveDebt() {
        let service = DebtService(modelContext: modelContext)
        let amount = Double(amountString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        guard let person = selectedPerson, let account = selectedAccount else {
            errorMessage = "Faltan datos (Persona o Cuenta)."
            return
        }
        
        do {
            if type == .receivable {
                try service.recordLoanGiven(amount: amount, currency: account.currency, date: date, person: person, account: account, desc: desc.isEmpty ? nil : desc)
            } else {
                try service.recordLoanReceived(amount: amount, currency: account.currency, date: date, person: person, account: account, desc: desc.isEmpty ? nil : desc)
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
