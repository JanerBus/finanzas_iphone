import SwiftUI
import SwiftData

struct CreditCardsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<CreditCard> { $0.isActive }, sort: \CreditCard.name) private var cards: [CreditCard]
    
    @State private var showingCreate = false
    
    var body: some View {
        List {
            if cards.isEmpty {
                Text("No hay tarjetas de crédito registradas.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(cards) { card in
                    NavigationLink(destination: CreditCardDetailView(card: card)) {
                        CreditCardRowView(card: card)
                    }
                }
            }
        }
        .navigationTitle("Mis Tarjetas")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCreate = true }) { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingCreate) {
            NavigationStack {
                CreateCreditCardView()
            }
        }
    }
}

struct CreditCardRowView: View {
    @Environment(\.modelContext) private var modelContext
    let card: CreditCard
    
    var body: some View {
        let service = CreditCardService(modelContext: modelContext)
        let utilized = service.calculateUtilizedBalance(for: card)
        let available = card.creditLimit - utilized
        
        HStack {
            VStack(alignment: .leading) {
                Text(card.name).font(.headline)
                Text(card.issuer ?? "").font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("Disp: \(available, specifier: "%.2f") \(card.currency)")
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.successColor)
                Text("Uso: \(utilized, specifier: "%.2f")")
                    .font(.caption2)
                    .foregroundColor(AppTheme.errorColor)
            }
        }
    }
}
