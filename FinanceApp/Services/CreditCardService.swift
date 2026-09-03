import Foundation
import SwiftData

@MainActor
public class CreditCardService {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func createCreditCard(name: String, issuer: String?, currency: String, limit: Double, closingDay: Int, dueDay: Int) throws {
        let card = CreditCard(name: name, issuer: issuer, currency: currency, creditLimit: limit, statementClosingDay: closingDay, paymentDueDay: dueDay)
        modelContext.insert(card)
        try modelContext.save()
    }
    
    // Regla 35: Compra es gasto, afecta cupo pero NO la cuenta bancaria.
    public func recordPurchase(card: CreditCard, amount: Double, merchant: String, date: Date, installmentsCount: Int, category: Category?) throws {
        guard amount > 0 else { throw FinanceError.invalidAmount }
        guard installmentsCount > 0 else { throw FinanceError.genericError("El número de cuotas debe ser al menos 1.") }
        
        let tx = Transaction(type: .creditCardPurchase, amount: amount, currency: card.currency, date: date, time: date, desc: merchant)
        tx.category = category
        tx.creditCard = card
        modelContext.insert(tx)
        
        let purchase = CreditCardPurchase(merchant: merchant, totalAmount: amount, currency: card.currency, numberOfInstallments: installmentsCount, purchaseDate: date)
        purchase.creditCard = card
        purchase.transaction = tx
        modelContext.insert(purchase)
        
        let installmentAmount = amount / Double(installmentsCount)
        var currentDate = date
        
        for i in 1...installmentsCount {
            currentDate = nextPaymentDate(from: currentDate, closingDay: card.statementClosingDay, dueDay: card.paymentDueDay, installmentIndex: i)
            let installment = Installment(installmentNumber: i, amount: installmentAmount, dueDate: currentDate)
            installment.purchase = purchase
            modelContext.insert(installment)
        }
        
        try modelContext.save()
    }
    
    // Regla 36: El pago descuenta de banco y limpia cuotas, pero NO genera el gasto de nuevo.
    public func recordPayment(card: CreditCard, amount: Double, account: Account, date: Date) throws {
        guard amount > 0 else { throw FinanceError.invalidAmount }
        
        let tx = Transaction(type: .creditCardPayment, amount: amount, currency: card.currency, date: date, time: date, desc: "Pago a \(card.name)")
        tx.creditCard = card
        modelContext.insert(tx)
        
        // LedgerEntry: Sale dinero de mi cuenta bancaria/efectivo
        let ledger = LedgerEntry(amount: -amount, currency: card.currency, createdAt: date)
        ledger.transaction = tx
        ledger.account = account
        modelContext.insert(ledger)
        
        // Saldar cuotas pendientes ordenadas cronológicamente
        var remainingPayment = amount
        let pendingInstallments = card.purchases
            .flatMap { $0.installments }
            .filter { $0.status == .pending }
            .sorted { $0.dueDate < $1.dueDate }
        
        for installment in pendingInstallments {
            if remainingPayment >= installment.amount {
                remainingPayment -= installment.amount
                installment.status = .paid
                installment.paidAt = date
            } else if remainingPayment > 0 {
                // Pago parcial de cuota
                installment.amount -= remainingPayment
                remainingPayment = 0
                break
            } else {
                break
            }
        }
        
        try modelContext.save()
    }
    
    public func calculateUtilizedBalance(for card: CreditCard) -> Double {
        let pending = card.purchases
            .flatMap { $0.installments }
            .filter { $0.status == .pending }
        return pending.reduce(0) { $0 + $1.amount }
    }
    
    public func calculateAvailableCredit(for card: CreditCard) -> Double {
        return card.creditLimit - calculateUtilizedBalance(for: card)
    }
    
    private func nextPaymentDate(from date: Date, closingDay: Int, dueDay: Int, installmentIndex: Int) -> Date {
        let calendar = Calendar.current
        if let futureMonth = calendar.date(byAdding: .month, value: installmentIndex, to: date) {
            let year = calendar.component(.year, from: futureMonth)
            let month = calendar.component(.month, from: futureMonth)
            var targetComps = DateComponents(year: year, month: month, day: dueDay)
            return calendar.date(from: targetComps) ?? date
        }
        return date
    }
}
