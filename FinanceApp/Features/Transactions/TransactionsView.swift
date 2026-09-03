import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    // Ordenamos las transacciones de más reciente a más antigua
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @State private var showingCreateSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                if transactions.isEmpty {
                    Text("No hay movimientos registrados.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(transactions) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                    .onDelete(perform: deleteTransactions)
                }
            }
            .navigationTitle("Movimientos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                NavigationStack {
                    CreateTransactionView()
                }
            }
        }
    }
    
    private func deleteTransactions(offsets: IndexSet) {
        let service = TransactionService(modelContext: modelContext)
        for index in offsets {
            let transaction = transactions[index]
            do {
                try service.deleteTransaction(transaction)
            } catch {
                print("Error al borrar transacción: \(error)")
            }
        }
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.desc ?? transaction.type.rawValue.capitalized)
                    .font(.headline)
                
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                let sign = (transaction.type == .expense) ? "-" : ((transaction.type == .income) ? "+" : "")
                let color = (transaction.type == .expense) ? AppTheme.errorColor : ((transaction.type == .income) ? AppTheme.successColor : .primary)
                
                Text("\(sign)\(transaction.amount, specifier: "%.2f") \(transaction.currency)")
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                Text(transaction.type.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}
