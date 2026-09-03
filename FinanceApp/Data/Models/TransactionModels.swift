import Foundation
import SwiftData

@Model
public final class Transaction {
    @Attribute(.unique) public var id: UUID
    public var type: TransactionType
    public var amount: Double
    public var currency: String
    public var date: Date
    public var time: Date
    public var desc: String?
    public var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \LedgerEntry.transaction)
    public var ledgerEntries: [LedgerEntry] = []
    
    // Relaciones opcionales (un movimiento puede pertenecer a distintas entidades)
    public var category: Category?
    public var subcategory: Subcategory?
    public var debt: Debt?
    public var creditCard: CreditCard?
    
    public init(id: UUID = UUID(), type: TransactionType, amount: Double, currency: String, date: Date, time: Date, desc: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.type = type
        self.amount = amount
        self.currency = currency
        self.date = date
        self.time = time
        self.desc = desc
        self.createdAt = createdAt
    }
}
