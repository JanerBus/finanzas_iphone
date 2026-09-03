import Foundation
import SwiftData

@MainActor
public class BalanceService {
    private let context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    public var primaryCurrency: String {
        let settings = (try? context.fetch(FetchDescriptor<UserSettings>())) ?? []
        return settings.first?.primaryCurrency ?? "COP"
    }
    
    public func convert(amount: Double, from currency: String, to targetCurrency: String) -> Double {
        if currency == targetCurrency { return amount }
        let rates = (try? context.fetch(FetchDescriptor<ExchangeRate>())) ?? []
        
        if let rate = rates.first(where: { $0.fromCurrency == currency && $0.toCurrency == targetCurrency }) {
            return amount * rate.rate
        }
        if let inverse = rates.first(where: { $0.fromCurrency == targetCurrency && $0.toCurrency == currency }) {
            return amount * (1.0 / inverse.rate)
        }
        // Retorna el monto original si no encuentra conversión para evitar romper la UI
        return amount 
    }
    
    public func calculateAvailableBalance(accounts: [Account]) -> Double {
        let target = primaryCurrency
        return accounts.reduce(0) { total, account in
            let accountBal = account.initialBalance + account.ledgerEntries.reduce(0) { $0 + $1.amount }
            let convertedBal = convert(amount: accountBal, from: account.currency, to: target)
            return total + convertedBal
        }
    }
    
    public func calculateReceivables(debts: [Debt]) -> Double {
        let target = primaryCurrency
        return debts
            .filter { $0.direction == .receivable && $0.status != .paid && $0.status != .cancelled }
            .reduce(0) { total, debt in
                total + convert(amount: debt.remainingAmount, from: debt.currency, to: target)
            }
    }
    
    public func calculatePayables(debts: [Debt], cards: [CreditCard]) -> Double {
        let target = primaryCurrency
        let debtsSum = debts
            .filter { $0.direction == .payable && $0.status != .paid && $0.status != .cancelled }
            .reduce(0) { total, debt in
                total + convert(amount: debt.remainingAmount, from: debt.currency, to: target)
            }
            
        let cardsSum = cards.reduce(0) { total, card in
            let pending = card.purchases.flatMap { $0.installments }.filter { $0.status == .pending }
            let cardPendingSum = pending.reduce(0) { $0 + $1.amount }
            return total + convert(amount: cardPendingSum, from: card.currency, to: target)
        }
        
        return debtsSum + cardsSum
    }
    
    public func calculateNetBalance(accounts: [Account], debts: [Debt], cards: [CreditCard]) -> Double {
        return calculateAvailableBalance(accounts: accounts) 
               + calculateReceivables(debts: debts) 
               - calculatePayables(debts: debts, cards: cards)
    }
    
    public func calculateCurrentMonthIncome(transactions: [Transaction]) -> Double {
        let target = primaryCurrency
        let (start, end) = currentMonthRange()
        return transactions
            .filter { $0.type == .income && $0.date >= start && $0.date <= end }
            .reduce(0) { total, tx in
                total + convert(amount: tx.amount, from: tx.currency, to: target)
            }
    }
    
    public func calculateCurrentMonthExpense(transactions: [Transaction]) -> Double {
        let target = primaryCurrency
        let (start, end) = currentMonthRange()
        return transactions
            .filter { ($0.type == .expense || $0.type == .creditCardPurchase) && $0.date >= start && $0.date <= end }
            .reduce(0) { total, tx in
                total + convert(amount: tx.amount, from: tx.currency, to: target)
            }
    }
    
    private func currentMonthRange() -> (Date, Date) {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let end = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: start)!
        return (start, end)
    }
}
