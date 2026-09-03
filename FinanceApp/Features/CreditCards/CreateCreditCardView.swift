import SwiftUI
import SwiftData

struct CreateCreditCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var issuer: String = ""
    @State private var currency: String = "COP"
    @State private var limitString: String = ""
    @State private var closingDay: Int = 15
    @State private var dueDay: Int = 30
    
    @State private var errorMessage: String?
    
    let days = Array(1...31)
    
    var body: some View {
        Form {
            Section(header: Text("Información General")) {
                TextField("Nombre (ej. Visa Gold)", text: $name)
                TextField("Banco Emisor (ej. Bancolombia)", text: $issuer)
                TextField("Moneda", text: $currency).autocapitalization(.allCharacters)
                TextField("Cupo Total", text: $limitString).keyboardType(.decimalPad)
            }
            
            Section(header: Text("Fechas")) {
                Picker("Día de corte", selection: $closingDay) {
                    ForEach(days, id: \.self) { day in Text("\(day)").tag(day) }
                }
                Picker("Día límite de pago", selection: $dueDay) {
                    ForEach(days, id: \.self) { day in Text("\(day)").tag(day) }
                }
            }
            
            if let error = errorMessage {
                Text(error).foregroundColor(AppTheme.errorColor).font(.footnote)
            }
        }
        .navigationTitle("Nueva Tarjeta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { Button("Cancelar") { dismiss() } }
            ToolbarItem(placement: .navigationBarTrailing) { Button("Guardar") { save() }.fontWeight(.bold) }
        }
    }
    
    private func save() {
        let service = CreditCardService(modelContext: modelContext)
        let limit = Double(limitString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        do {
            try service.createCreditCard(name: name, issuer: issuer.isEmpty ? nil : issuer, currency: currency, limit: limit, closingDay: closingDay, dueDay: dueDay)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
