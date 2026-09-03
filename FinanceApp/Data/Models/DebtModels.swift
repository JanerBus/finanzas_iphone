import Foundation
import SwiftData

@Model
public final class Person {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var phone: String?
    public var email: String?
    public var notes: String?
    public var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Debt.person)
    public var debts: [Debt] = []
    
    public init(id: UUID = UUID(), name: String, phone: String? = nil, email: String? = nil, notes: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.notes = notes
        self.createdAt = createdAt
    }
}

@Model
public final class Debt {
    @Attribute(.unique) public var id: UUID
    public var direction: DebtDirection
    public var originalAmount: Double
    public var currency: String
    public var remainingAmount: Double
    public var status: DebtStatus
    public var dueDate: Date?
    public var desc: String?
    public var createdAt: Date
    
    public var person: Person?
    
    @Relationship(deleteRule: .cascade, inverse: \DebtPayment.debt)
    public var payments: [DebtPayment] = []
    
    public init(id: UUID = UUID(), direction: DebtDirection, originalAmount: Double, currency: String, remainingAmount: Double, status: DebtStatus = .pending, dueDate: Date? = nil, desc: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.direction = direction
        self.originalAmount = originalAmount
        self.currency = currency
        self.remainingAmount = remainingAmount
        self.status = status
        self.dueDate = dueDate
        self.desc = desc
        self.createdAt = createdAt
    }
}

@Model
public final class DebtPayment {
    @Attribute(.unique) public var id: UUID
    public var amount: Double
    public var currency: String
    public var date: Date
    public var notes: String?
    
    public var debt: Debt?
    public var transaction: Transaction?
    
    public init(id: UUID = UUID(), amount: Double, currency: String, date: Date, notes: String? = nil) {
        self.id = id
        self.amount = amount
        self.currency = currency
        self.date = date
        self.notes = notes
    }
}
