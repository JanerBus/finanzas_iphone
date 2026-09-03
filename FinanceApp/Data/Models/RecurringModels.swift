import Foundation
import SwiftData

@Model
public final class RecurringExpense {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var amount: Double
    public var currency: String
    public var frequency: Frequency
    public var nextOccurrence: Date
    public var isActive: Bool
    
    public var account: Account?
    public var category: Category?
    
    public init(id: UUID = UUID(), name: String, amount: Double, currency: String, frequency: Frequency, nextOccurrence: Date, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.amount = amount
        self.currency = currency
        self.frequency = frequency
        self.nextOccurrence = nextOccurrence
        self.isActive = isActive
    }
}
