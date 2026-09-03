import Foundation
import SwiftData

@MainActor
public class DebtService {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func createPerson(name: String, phone: String?, email: String?, notes: String?) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { throw FinanceError.genericError("El nombre de la persona es obligatorio.") }
        let person = Person(name: trimmedName, phone: phone, email: email, notes: notes)
        modelContext.insert(person)
        try modelContext.save()
    }
    
    // REGLA: Prestar dinero (Sale de mi cuenta disponible, se crea cuenta por cobrar)
    public func recordLoanGiven(amount: Double, currency: String, date: Date, person: Person, account: Account, desc: String?) throws {
        guard amount > 0 else { throw FinanceError.invalidAmount }
        
        let tx = Transaction(type: .loanGiven, amount: amount, currency: currency, date: date, time: date, desc: desc)
        modelContext.insert(tx)
        
        let ledger = LedgerEntry(amount: -amount, currency: currency, createdAt: date)
        ledger.transaction = tx
        ledger.account = account
        modelContext.insert(ledger)
        
        let debt = Debt(direction: .receivable, originalAmount: amount, currency: currency, remainingAmount: amount, status: .pending, desc: desc, createdAt: date)
        debt.person = person
        tx.debt = debt
        modelContext.insert(debt)
        
        try modelContext.save()
    }
    
    // REGLA: Recibir préstamo (Entra a mi cuenta, se crea cuenta por pagar)
    public func recordLoanReceived(amount: Double, currency: String, date: Date, person: Person, account: Account, desc: String?) throws {
        guard amount > 0 else { throw FinanceError.invalidAmount }
        
        let tx = Transaction(type: .loanReceived, amount: amount, currency: currency, date: date, time: date, desc: desc)
        modelContext.insert(tx)
        
        let ledger = LedgerEntry(amount: amount, currency: currency, createdAt: date)
        ledger.transaction = tx
        ledger.account = account
        modelContext.insert(ledger)
        
        let debt = Debt(direction: .payable, originalAmount: amount, currency: currency, remainingAmount: amount, status: .pending, desc: desc, createdAt: date)
        debt.person = person
        tx.debt = debt
        modelContext.insert(debt)
        
        try modelContext.save()
    }
    
    // REGLA: Pago de deuda o Cobro de préstamo parcial/total
    public func recordDebtPayment(debt: Debt, amount: Double, account: Account, date: Date, notes: String?) throws {
        guard amount > 0 else { throw FinanceError.invalidAmount }
        guard amount <= debt.remainingAmount else { throw FinanceError.genericError("El pago no puede superar el saldo pendiente.") }
        
        let isReceivable = debt.direction == .receivable
        let txType: TransactionType = isReceivable ? .debtCollection : .debtPayment
        
        let tx = Transaction(type: txType, amount: amount, currency: debt.currency, date: date, time: date, desc: notes)
        tx.debt = debt
        modelContext.insert(tx)
        
        // Si cobro (.receivable), entra dinero a la cuenta (+). Si pago (.payable), sale (-)
        let ledgerAmount = isReceivable ? amount : -amount
        let ledger = LedgerEntry(amount: ledgerAmount, currency: debt.currency, createdAt: date)
        ledger.transaction = tx
        ledger.account = account
        modelContext.insert(ledger)
        
        let payment = DebtPayment(amount: amount, currency: debt.currency, date: date, notes: notes)
        payment.debt = debt
        payment.transaction = tx
        modelContext.insert(payment)
        
        debt.remainingAmount -= amount
        debt.status = debt.remainingAmount == 0 ? .paid : .partiallyPaid
        
        try modelContext.save()
    }
}
