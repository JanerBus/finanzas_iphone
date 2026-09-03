import SwiftUI
import SwiftData

@main
struct FinanceApp: App {
    // Configuración central de SwiftData. Inyectará el ModelContext al resto de la aplicación.
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
            ExchangeRate.self
        ])
        
        // isStoredInMemoryOnly: false para que los datos persistan en el almacenamiento local.
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
        // Inyección del contenedor a toda la jerarquía de vistas
        .modelContainer(sharedModelContainer)
    }
}
