import SwiftUI
import SwiftData

struct CreditCardDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let card: CreditCard
    
    @State private var showingPurchase = false
    @State private var showingPayment = false
    
    var body: some View {
        let service = CreditCardService(modelContext: modelContext)
        let utilized = service.calculateUtilizedBalance(for: card)
        let available = card.creditLimit - utilized
        
        List {
            Section(header: Text("Estado Actual")) {
                HStack { Text("Cupo Total"); Spacer(); Text("\(card.creditLimit, specifier: "%.2f") \(card.currency)") }
                HStack { Text("Cupo Disponible"); Spacer(); Text("\(available, specifier: "%.2f")").foregroundColor(AppTheme.successColor).fontWeight(.bold) }
                HStack { Text("Saldo Utilizado"); Spacer(); Text("\(utilized, specifier: "%.2f")").foregroundColor(AppTheme.errorColor) }
            }
            
            Section {
                Button("Registrar Compra") { showingPurchase = true }
                Button("Pagar Tarjeta") { showingPayment = true }
            }
            
            Section(header: Text("Compras con Saldo Pendiente")) {
                let pendingPurchases = card.purchases.filter { purchase in
                    purchase.installments.contains(where: { $0.status == .pending })
                }.sorted(by: { $0.purchaseDate > $1.purchaseDate })
                
                if pendingPurchases.isEmpty {
                    Text("No debes nada por ahora.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(pendingPurchases) { purchase in
                        let remaining = purchase.installments.filter { $0.status == .pending }.reduce(0) { $0 + $1.amount }
                        HStack {
                            VStack(alignment: .leading) {
                                Text(purchase.merchant).font(.headline)
                                Text("\(purchase.numberOfInstallments) cuotas").font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(remaining, specifier: "%.2f")").foregroundColor(AppTheme.errorColor)
                        }
                    }
                }
            }
        }
        .navigationTitle(card.name)
        .sheet(isPresented: $showingPurchase) {
            NavigationStack { RecordCardPurchaseView(card: card) }
        }
        .sheet(isPresented: $showingPayment) {
            NavigationStack { RecordCardPaymentView(card: card) }
        }
    }
}
