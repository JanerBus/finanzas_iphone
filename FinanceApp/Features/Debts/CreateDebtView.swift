import SwiftUI
import SwiftData

struct CreateDebtView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Person.name) private var persons: [Person]
    @Query(filter: #Predicate<Account> { $0.isActive }) private var accounts: [Account]
    
    @State private var isReceivable = true 
    @State private var amountString = ""
    @State private var selectedPerson: Person?
    @State private var selectedAccount: Account?
    
    @State private var showNewPersonForm = false
    @State private var newPersonName = ""
    @State private var newPersonPhone = ""
    
    @State private var errorMessage: String?
    
    var isFormValid: Bool {
        if showNewPersonForm {
            return !newPersonName.trimmingCharacters(in: .whitespaces).isEmpty && !amountString.isEmpty && selectedAccount != nil
        } else {
            return selectedPerson != nil && !amountString.isEmpty && selectedAccount != nil
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Tipo de Deuda")) {
                Picker("Tipo", selection: $isReceivable) {
                    Text("Prestar dinero (Me deben)").tag(true)
                    Text("Pedir prestado (Yo debo)").tag(false)
                }
                .pickerStyle(.segmented)
            }
            
            Section(header: Text("Contacto")) {
                if !showNewPersonForm {
                    if persons.isEmpty {
                        Text("No tienes contactos. Crea uno nuevo.")
                            .foregroundColor(.secondary)
                            .onAppear { showNewPersonForm = true }
                    } else {
                        Picker("Persona", selection: $selectedPerson) {
                            Text("Seleccione").tag(nil as Person?)
                            ForEach(persons) { person in
                                Text(person.name).tag(person as Person?)
                            }
                        }
                    }
                    
                    Button(action: { showNewPersonForm = true }) {
                        Label("Crear Nuevo Contacto", systemImage: "person.badge.plus")
                    }
                } else {
                    TextField("Nombre del Contacto", text: $newPersonName)
                    TextField("Teléfono (Opcional)", text: $newPersonPhone)
                        .keyboardType(.phonePad)
                    
                    if !persons.isEmpty {
                        Button("Elegir existente") { showNewPersonForm = false }
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Section(header: Text("Detalles del Préstamo")) {
                TextField("Monto", text: $amountString)
                    .keyboardType(.decimalPad)
                
                Picker(isReceivable ? "De dónde sale el dinero" : "A dónde entra el dinero", selection: $selectedAccount) {
                    Text("Seleccione").tag(nil as Account?)
                    ForEach(accounts) { account in
                        Text(account.name).tag(account as Account?)
                    }
                }
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(AppTheme.errorColor)
                    .font(.footnote)
            }
        }
        .navigationTitle(isReceivable ? "Nuevo Préstamo" : "Adquirir Deuda")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { Button("Cancelar") { dismiss() } }
            ToolbarItem(placement: .navigationBarTrailing) { 
                Button("Guardar") { save() }
                    .fontWeight(.bold)
                    .disabled(!isFormValid)
            }
        }
    }
    
    private func save() {
        let service = DebtService(modelContext: modelContext)
        let amount = Double(amountString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        guard let account = selectedAccount else {
            errorMessage = "Selecciona una cuenta válida."
            return
        }
        
        do {
            let personToUse: Person
            if showNewPersonForm {
                personToUse = try service.createPerson(name: newPersonName, phone: newPersonPhone.isEmpty ? nil : newPersonPhone)
            } else {
                guard let selected = selectedPerson else {
                    errorMessage = "Selecciona una persona."
                    return
                }
                personToUse = selected
            }
            
            if isReceivable {
                try service.recordLoanGiven(to: personToUse, amount: amount, fromAccount: account, date: Date())
            } else {
                try service.recordLoanReceived(from: personToUse, amount: amount, toAccount: account, date: Date())
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
