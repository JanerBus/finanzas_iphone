import Foundation
import SwiftData

@MainActor
public class AccountService {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func createAccount(name: String, type: AccountType, currency: String, initialBalance: Double, notes: String?) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            throw NSError(domain: "AccountError", code: 1, userInfo: [NSLocalizedDescriptionKey: "El nombre de la cuenta no puede estar vacío."])
        }
        
        let newAccount = Account(name: trimmedName, type: type, currency: currency.uppercased(), initialBalance: initialBalance, notes: notes)
        modelContext.insert(newAccount)
        
        try modelContext.save()
    }
    
    public func toggleAccountActiveStatus(account: Account) throws {
        account.isActive.toggle()
        try modelContext.save()
    }
    
    // Regla de Negocio: Saldo se deriva reconstruyéndolo desde el LedgerEntry + Saldo Inicial
    public func calculateBalance(for account: Account) -> Double {
        let entriesSum = account.ledgerEntries.reduce(0.0) { $0 + $1.amount }
        return account.initialBalance + entriesSum
    }
}
