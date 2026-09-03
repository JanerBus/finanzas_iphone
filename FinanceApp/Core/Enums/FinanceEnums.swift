import Foundation

public enum AccountType: String, Codable {
    case cash
    case bank
    case digitalWallet
    case savings
    case other
}

public enum TransactionType: String, Codable {
    case expense
    case income
    case transfer
    case loanGiven
    case loanReceived
    case debtPayment
    case debtCollection
    case creditCardPurchase
    case creditCardPayment
}

public enum DebtDirection: String, Codable {
    case receivable // Dinero que me deben
    case payable    // Dinero que debo
}

public enum DebtStatus: String, Codable {
    case pending
    case partiallyPaid
    case paid
    case overdue
    case cancelled
}

public enum InstallmentStatus: String, Codable {
    case pending
    case paid
    case overdue
}

public enum Frequency: String, Codable {
    case daily
    case weekly
    case biweekly
    case monthly
    case yearly
}
