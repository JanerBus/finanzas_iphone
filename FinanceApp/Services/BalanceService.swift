import Foundation

public class BalanceService {
    
    public init() {}
    
    // Regla 39: Balance General (Efectivo + Bancos + Billeteras)
    public func calculateAvailableBalance(accounts: [Account]) -> Double {
        return accounts.reduce(0) { total, account in
            total + account.initialBalance + account.ledgerEntries.reduce(0) { $0 + $1.amount }
        }
    }
    
    // Regla 39: Dinero por cobrar
    public func calculateReceivables(debts: [Debt]) -> Double {
        return debts
            .filter { $0.direction == .receivable && $0.status != .paid && $0.status != .cancelled }
            .reduce(0) { $0 + $1.remainingAmount }
    }
    
    // Regla 39: Dinero por pagar (Personas + Tarjetas)
    public func calculatePayables(debts: [Debt], cards: [CreditCard]) -> Double {
        let debtsSum = debts
            .filter { $0.direction == .payable && $0.status != .paid && $0.status != .cancelled }
            .reduce(0) { $0 + $1.remainingAmount }
            
        let cardsSum = cards.reduce(0) { total, card in
            let pending = card.purchases.flatMap { $0.installments }.filter { $0.status == .pending }
            return total + pending.reduce(0) { $0 + $1.amount }
        }
        
        return debtsSum + cardsSum
    }
    
    // Patrimonio Neto
    public func calculateNetBalance(accounts: [Account], debts: [Debt], cards: [CreditCard]) -> Double {
        return calculateAvailableBalance(accounts: accounts) 
               + calculateReceivables(debts: debts) 
               - calculatePayables(debts: debts, cards: cards)
    }
    
    // Ingresos del mes actual
    public func calculateCurrentMonthIncome(transactions: [Transaction]) -> Double {
        let (start, end) = currentMonthRange()
        return transactions
            .filter { $0.type == .income && $0.date >= start && $0.date <= end }
            .reduce(0) { $0 + $1.amount }
    }
    
    // Gastos del mes actual (Gastos ordinarios + Compras con tarjeta)
    public func calculateCurrentMonthExpense(transactions: [Transaction]) -> Double {
        let (start, end) = currentMonthRange()
        return transactions
            .filter { ($0.type == .expense || $0.type == .creditCardPurchase) && $0.date >= start && $0.date <= end }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func currentMonthRange() -> (Date, Date) {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let end = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: start)!
        return (start, end)
    }
}
