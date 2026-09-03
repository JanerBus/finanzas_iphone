import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(filter: #Predicate<Account> { $0.isActive }) private var accounts: [Account]
    @Query private var debts: [Debt]
    @Query(filter: #Predicate<CreditCard> { $0.isActive }) private var cards: [CreditCard]
    @Query private var transactions: [Transaction]
    @Query(filter: #Predicate<RecurringExpense> { $0.isActive }) private var allRecurring: [RecurringExpense]
    
    var pendingRecurring: [RecurringExpense] {
        let now = Date()
        return allRecurring.filter { $0.nextOccurrence <= now }.sorted(by: { $0.nextOccurrence < $1.nextOccurrence })
    }
    
    var body: some View {
        let balanceService = BalanceService(context: modelContext)
        let primaryCurrency = balanceService.primaryCurrency
        
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
                        
                        Text("\(net >= 0 ? "" : "-")\(abs(net), specifier: "%.2f") \(primaryCurrency)")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(net >= 0 ? .primary : AppTheme.errorColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                        HStack(spacing: 15) {
                            BalanceMetricView(title: "Disponible", amount: available, color: AppTheme.primaryColor)
                            BalanceMetricView(title: "Me Deben", amount: receivables, color: AppTheme.successColor)
                            BalanceMetricView(title: "Yo Debo", amount: payables, color: AppTheme.errorColor)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Resumen del Mes (\(primaryCurrency))")) {
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
