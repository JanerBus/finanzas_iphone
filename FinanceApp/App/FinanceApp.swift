import SwiftUI
import SwiftData

@main
struct FinanceApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Account.self,
            LedgerEntry.self,
            Transaction.self,
            Category.self,
            Subcategory.self,
            Person.self,
            Debt.self,
            DebtPayment.self,
            CreditCard.self,
            CreditCardPurchase.self,
            Installment.self,
            UserSettings.self,
            Currency.self,
            ExchangeRate.self,
            RecurringExpense.self // Agregado en Fase 6
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
