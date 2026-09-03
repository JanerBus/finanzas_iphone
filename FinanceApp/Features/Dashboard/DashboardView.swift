import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Consultas Reactivas. Si algo cambia en la app, esta vista se redibuja automáticamente.
    @Query(filter: #Predicate<Account> { $0.isActive }) private var accounts: [Account]
    @Query private var debts: [Debt]
    @Query(filter: #Predicate<CreditCard> { $0.isActive }) private var cards: [CreditCard]
    @Query private var transactions: [Transaction]
    @Query(filter: #Predicate<RecurringExpense> { $0.isActive }) private var allRecurring: [RecurringExpense]
    
    let balanceService = BalanceService()
    
    var pendingRecurring: [RecurringExpense] {
        let now = Date()
        return allRecurring.filter { $0.nextOccurrence <= now }.sorted(by: { $0.nextOccurrence < $1.nextOccurrence })
    }
    
    var body: some View {
        let available = balanceService.calculateAvailableBalance(accounts: accounts)
        let receivables = balanceService.calculateReceivables(debts: debts)
        let payables = balanceService.calculatePayables(debts: debts, cards: cards)
        let net = balanceService.calculateNetBalance(accounts: accounts, debts: debts, cards: cards)
        let income = balanceService.calculateCurrentMonthIncome(transactions: transactions)
        let expense = balanceService.calculateCurrentMonthExpense(transactions: transactions)
        
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 20) {
                        Text("Patrimonio Neto")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(net >= 0 ? "" : "-")\(abs(net), specifier: "%.2f")")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(net >= 0 ? .primary : AppTheme.errorColor)
                        
                        HStack(spacing: 15) {
                            BalanceMetricView(title: "Disponible", amount: available, color: AppTheme.primaryColor)
                            BalanceMetricView(title: "Me Deben", amount: receivables, color: AppTheme.successColor)
                            BalanceMetricView(title: "Yo Debo", amount: payables, color: AppTheme.errorColor)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Resumen del Mes")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Ingresos").font(.caption).foregroundColor(.secondary)
                            Text("\(income, specifier: "%.2f")").fontWeight(.semibold).foregroundColor(AppTheme.successColor)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Gastos").font(.caption).foregroundColor(.secondary)
                            Text("\(expense, specifier: "%.2f")").fontWeight(.semibold).foregroundColor(AppTheme.errorColor)
                        }
                    }
                }
                
                if !pendingRecurring.isEmpty {
                    Section(header: Text("Gastos Recurrentes Pendientes")) {
                        ForEach(pendingRecurring) { expense in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(expense.name).font(.headline)
                                    Spacer()
                                    Text("\(expense.amount, specifier: "%.2f") \(expense.currency)")
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.errorColor)
                                }
                                HStack {
                                    Button("Omitir") { skip(expense) }.buttonStyle(.bordered).tint(.secondary)
                                    Spacer()
                                    Button("Registrar Gasto") { record(expense) }.buttonStyle(.borderedProminent)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Section(header: Text("Accesos Rápidos")) {
                    NavigationLink(destination: AccountsListView()) {
                        Label("Mis Cuentas", systemImage: "building.columns.fill")
                    }
                    NavigationLink(destination: CreditCardsListView()) {
                        Label("Tarjetas de Crédito", systemImage: "creditcard.fill")
                    }
                }
            }
            .navigationTitle("Inicio")
        }
    }
    
    private func skip(_ expense: RecurringExpense) {
        let service = RecurringExpenseService(modelContext: modelContext)
        try? service.skipOccurrence(expense)
    }
    
    private func record(_ expense: RecurringExpense) {
        let service = RecurringExpenseService(modelContext: modelContext)
        try? service.recordOccurrence(expense: expense)
    }
}

struct BalanceMetricView: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("\(amount >= 0 ? "" : "-")\(abs(amount), specifier: "%.0f")")
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}
