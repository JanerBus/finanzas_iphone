import Foundation
import SwiftData

@Model
public final class Account {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var type: AccountType
    public var currency: String
    public var initialBalance: Double
    public var isActive: Bool
    public var createdAt: Date
    public var notes: String?
    
    @Relationship(deleteRule: .cascade, inverse: \LedgerEntry.account)
    public var ledgerEntries: [LedgerEntry] = []
    
    public init(id: UUID = UUID(), name: String, type: AccountType, currency: String, initialBalance: Double, isActive: Bool = true, createdAt: Date = Date(), notes: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.currency = currency
        self.initialBalance = initialBalance
        self.isActive = isActive
        self.createdAt = createdAt
        self.notes = notes
    }
}

@Model
public final class LedgerEntry {
    @Attribute(.unique) public var id: UUID
    public var amount: Double
    public var currency: String
    public var createdAt: Date
    
    public var account: Account?
    public var transaction: Transaction?
    
    public init(id: UUID = UUID(), amount: Double, currency: String, createdAt: Date = Date()) {
        self.id = id
        self.amount = amount
        self.currency = currency
        self.createdAt = createdAt
    }
}
