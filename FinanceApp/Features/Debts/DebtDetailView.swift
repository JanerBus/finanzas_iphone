import SwiftUI
import SwiftData

struct DebtDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let debt: Debt
    
    @Query(filter: #Predicate<Account> { $0.isActive }) private var accounts: [Account]
    
    @State private var showingPaymentSheet = false
    @State private var paymentAmountString = ""
    @State private var selectedAccount: Account?
    @State private var paymentErrorMessage: String?
    
    var body: some View {
        List {
            Section(header: Text("Resumen")) {
                HStack {
                    Text("Original")
                    Spacer()
                    Text("\(debt.originalAmount, specifier: "%.2f") \(debt.currency)")
                }
                HStack {
                    Text("Pendiente")
                    Spacer()
                    Text("\(debt.remainingAmount, specifier: "%.2f") \(debt.currency)")
                        .fontWeight(.bold)
                }
                HStack {
                    Text("Estado")
                    Spacer()
                    Text(debt.status.rawValue.capitalized)
                }
            }
            
            Section(header: Text("Historial de Pagos")) {
                if debt.payments.isEmpty {
                    Text("No hay pagos registrados.")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                } else {
                    ForEach(debt.payments.sorted(by: { $0.date > $1.date })) { payment in
                        HStack {
                            Text(payment.date, style: .date)
                            Spacer()
                            Text("\(payment.amount, specifier: "%.2f")")
                        }
                    }
                }
            }
            
            if debt.status != .paid {
                Button(action: { showingPaymentSheet = true }) {
                    Text(debt.direction == .receivable ? "Registrar Cobro" : "Registrar Pago")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle(debt.person?.name ?? "Detalle")
        .sheet(isPresented: $showingPaymentSheet) {
            NavigationStack {
                Form {
                    Section {
                        TextField("Monto (Max: \(debt.remainingAmount, specifier: "%.2f"))", text: $paymentAmountString)
                            .keyboardType(.decimalPad)
                        
                        Picker("Cuenta Afectada", selection: $selectedAccount) {
                            Text("Seleccione").tag(nil as Account?)
                            ForEach(accounts) { account in
                                Text(account.name).tag(account as Account?)
                            }
                        }
                        
                        if let err = paymentErrorMessage {
                            Text(err).foregroundColor(AppTheme.errorColor).font(.footnote)
                        }
                    }
                }
                .navigationTitle(debt.direction == .receivable ? "Registrar Cobro" : "Registrar Pago")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancelar") { showingPaymentSheet = false }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Confirmar") { processPayment() }
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
    
    private func processPayment() {
        let service = DebtService(modelContext: modelContext)
        let amount = Double(paymentAmountString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        guard let account = selectedAccount else {
            paymentErrorMessage = "Seleccione una cuenta para aplicar el saldo."
            return
        }
        
        do {
            try service.recordDebtPayment(debt: debt, amount: amount, account: account, date: Date(), notes: nil)
            showingPaymentSheet = false
            paymentAmountString = ""
        } catch {
            paymentErrorMessage = error.localizedDescription
        }
    }
}
