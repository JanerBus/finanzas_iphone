import Foundation
import SwiftData

@MainActor
public class TransactionService {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func recordExpense(amount: Double, currency: String, date: Date, desc: String?, category: Category?, account: Account) throws {
        guard amount > 0 else { throw FinanceError.invalidAmount }
        
        // 1. Crear Transacción (Registro lógico)
        let transaction = Transaction(type: .expense, amount: amount, currency: currency, date: date, time: date, desc: desc)
        transaction.category = category
        modelContext.insert(transaction)
        
        // 2. Crear LedgerEntry (Impacto contable: negativo para salidas)
        let ledger = LedgerEntry(amount: -amount, currency: currency, createdAt: date)
        ledger.transaction = transaction
        ledger.account = account
        modelContext.insert(ledger)
        
        try modelContext.save()
    }
    
    public func recordIncome(amount: Double, currency: String, date: Date, desc: String?, category: Category?, account: Account) throws {
        guard amount > 0 else { throw FinanceError.invalidAmount }
        
        let transaction = Transaction(type: .income, amount: amount, currency: currency, date: date, time: date, desc: desc)
        transaction.category = category
        modelContext.insert(transaction)
        
        // Impacto contable: positivo para entradas
        let ledger = LedgerEntry(amount: amount, currency: currency, createdAt: date)
        ledger.transaction = transaction
        ledger.account = account
        modelContext.insert(ledger)
        
        try modelContext.save()
    }
    
    public func recordTransfer(amount: Double, currency: String, date: Date, desc: String?, fromAccount: Account, toAccount: Account) throws {
        guard amount > 0 else { throw FinanceError.invalidAmount }
        guard fromAccount.id != toAccount.id else { throw FinanceError.sameAccountTransfer }
        
        let transaction = Transaction(type: .transfer, amount: amount, currency: currency, date: date, time: date, desc: desc)
        modelContext.insert(transaction)
        
        // Salida de la cuenta origen
        let ledgerOut = LedgerEntry(amount: -amount, currency: fromAccount.currency, createdAt: date)
        ledgerOut.transaction = transaction
        ledgerOut.account = fromAccount
        modelContext.insert(ledgerOut)
        
        // Entrada a la cuenta destino
        let ledgerIn = LedgerEntry(amount: amount, currency: toAccount.currency, createdAt: date)
        ledgerIn.transaction = transaction
        ledgerIn.account = toAccount
        modelContext.insert(ledgerIn)
        
        try modelContext.save()
    }
    
    public func deleteTransaction(_ transaction: Transaction) throws {
        // Al borrar la transacción, el 'deleteRule: .cascade' eliminará sus LedgerEntries automáticamente.
        // Esto revierte el impacto en el balance inmediatamente.
        modelContext.delete(transaction)
        try modelContext.save()
    }
}
