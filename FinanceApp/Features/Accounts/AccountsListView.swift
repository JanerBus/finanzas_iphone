import SwiftUI
import SwiftData

struct AccountsListView: View {
    @Environment(\.modelContext) private var modelContext
    // SwiftData actualiza la UI automáticamente cuando las cuentas cambian
    @Query(filter: #Predicate<Account> { $0.isActive }, sort: \Account.name) private var activeAccounts: [Account]
    @Query(filter: #Predicate<Account> { !$0.isActive }, sort: \Account.name) private var inactiveAccounts: [Account]
    
    @State private var showingCreateSheet = false
    
    var body: some View {
        List {
            Section(header: Text("Cuentas Activas")) {
                if activeAccounts.isEmpty {
                    Text("No hay cuentas activas")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(activeAccounts) { account in
                        NavigationLink(destination: AccountDetailView(account: account)) {
                            AccountRowView(account: account)
                        }
                    }
                }
            }
            
            if !inactiveAccounts.isEmpty {
                Section(header: Text("Cuentas Inactivas")) {
                    ForEach(inactiveAccounts) { account in
                        NavigationLink(destination: AccountDetailView(account: account)) {
                            AccountRowView(account: account)
                                .opacity(0.6)
                        }
                    }
                }
            }
        }
        .navigationTitle("Cuentas")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCreateSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            NavigationStack {
                CreateAccountView()
            }
        }
    }
}

struct AccountRowView: View {
    let account: Account
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(account.name)
                    .font(.headline)
                Text(account.type.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            // Saldo derivado dinámicamente
            let balance = account.initialBalance + account.ledgerEntries.reduce(0) { $0 + $1.amount }
            Text("\(balance, specifier: "%.2f") \(account.currency)")
                .fontWeight(.semibold)
                .foregroundColor(balance >= 0 ? .primary : AppTheme.errorColor)
        }
    }
}
