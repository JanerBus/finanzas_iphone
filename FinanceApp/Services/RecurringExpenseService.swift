import Foundation
import SwiftData

@MainActor
public class RecurringExpenseService {
    private let modelContext: ModelContext
    private let transactionService: TransactionService
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.transactionService = TransactionService(modelContext: modelContext)
    }
    
    public func createRecurringExpense(name: String, amount: Double, currency: String, frequency: Frequency, firstOccurrence: Date, account: Account?) throws {
        guard amount > 0 else { throw FinanceError.invalidAmount }
        
        let expense = RecurringExpense(name: name.trimmingCharacters(in: .whitespaces), amount: amount, currency: currency, frequency: frequency, nextOccurrence: firstOccurrence)
        expense.account = account
        modelContext.insert(expense)
        
        try modelContext.save()
    }
    
    public func recordOccurrence(expense: RecurringExpense) throws {
        guard let account = expense.account else {
            throw FinanceError.genericError("El gasto recurrente no tiene una cuenta configurada para el cobro.")
        }
        
        // 1. Registrar el gasto real delegando en el TransactionService
        try transactionService.recordExpense(
            amount: expense.amount,
            currency: expense.currency,
            date: Date(), // Se registra con fecha de hoy (cuándo se confirmó)
            desc: "Recurrente: \(expense.name)",
            category: expense.category,
            account: account
        )
        
        // 2. Reprogramar la próxima fecha
        expense.nextOccurrence = advanceDate(from: expense.nextOccurrence, frequency: expense.frequency)
        try modelContext.save()
    }
    
    public func skipOccurrence(expense: RecurringExpense) throws {
        // Solo reprograma, no crea transacción
        expense.nextOccurrence = advanceDate(from: expense.nextOccurrence, frequency: expense.frequency)
        try modelContext.save()
    }
    
    public func deleteExpense(_ expense: RecurringExpense) throws {
        modelContext.delete(expense)
        try modelContext.save()
    }
    
    private func advanceDate(from date: Date, frequency: Frequency) -> Date {
        var components = DateComponents()
        switch frequency {
        case .daily: components.day = 1
        case .weekly: components.day = 7
        case .biweekly: components.day = 14
        case .monthly: components.month = 1
        case .yearly: components.year = 1
        }
        return Calendar.current.date(byAdding: components, to: date) ?? date
    }
}
