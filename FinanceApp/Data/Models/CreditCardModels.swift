import Foundation
import SwiftData

@Model
public final class CreditCard {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var issuer: String?
    public var currency: String
    public var creditLimit: Double
    public var statementClosingDay: Int
    public var paymentDueDay: Int
    public var isActive: Bool
    public var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \CreditCardPurchase.creditCard)
    public var purchases: [CreditCardPurchase] = []
    
    public init(id: UUID = UUID(), name: String, issuer: String? = nil, currency: String, creditLimit: Double, statementClosingDay: Int, paymentDueDay: Int, isActive: Bool = true, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.issuer = issuer
        self.currency = currency
        self.creditLimit = creditLimit
        self.statementClosingDay = statementClosingDay
        self.paymentDueDay = paymentDueDay
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

@Model
public final class CreditCardPurchase {
    @Attribute(.unique) public var id: UUID
    public var merchant: String
    public var totalAmount: Double
    public var currency: String
    public var numberOfInstallments: Int
    public var purchaseDate: Date
    
    public var creditCard: CreditCard?
    public var transaction: Transaction?
    
    @Relationship(deleteRule: .cascade, inverse: \Installment.purchase)
    public var installments: [Installment] = []
    
    public init(id: UUID = UUID(), merchant: String, totalAmount: Double, currency: String, numberOfInstallments: Int, purchaseDate: Date = Date()) {
        self.id = id
        self.merchant = merchant
        self.totalAmount = totalAmount
        self.currency = currency
        self.numberOfInstallments = numberOfInstallments
        self.purchaseDate = purchaseDate
    }
}

@Model
public final class Installment {
    @Attribute(.unique) public var id: UUID
    public var installmentNumber: Int
    public var amount: Double
    public var dueDate: Date
    public var status: InstallmentStatus
    public var paidAt: Date?
    
    public var purchase: CreditCardPurchase?
    
    public init(id: UUID = UUID(), installmentNumber: Int, amount: Double, dueDate: Date, status: InstallmentStatus = .pending, paidAt: Date? = nil) {
        self.id = id
        self.installmentNumber = installmentNumber
        self.amount = amount
        self.dueDate = dueDate
        self.status = status
        self.paidAt = paidAt
    }
}
