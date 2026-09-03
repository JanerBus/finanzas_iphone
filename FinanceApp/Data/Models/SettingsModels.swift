import Foundation
import SwiftData

@Model
public final class UserSettings {
    public var primaryCurrency: String
    public var appearanceRawValue: String
    
    public init(primaryCurrency: String = "COP", appearanceRawValue: String = "system") {
        self.primaryCurrency = primaryCurrency
        self.appearanceRawValue = appearanceRawValue
    }
}

@Model
public final class Currency {
    @Attribute(.unique) public var code: String
    public var name: String
    public var symbol: String
    public var decimalPlaces: Int
    
    public init(code: String, name: String, symbol: String, decimalPlaces: Int) {
        self.code = code
        self.name = name
        self.symbol = symbol
        self.decimalPlaces = decimalPlaces
    }
}

@Model
public final class ExchangeRate {
    @Attribute(.unique) public var id: UUID
    public var fromCurrency: String
    public var toCurrency: String
    public var rate: Double
    public var date: Date
    
    public init(id: UUID = UUID(), fromCurrency: String, toCurrency: String, rate: Double, date: Date = Date()) {
        self.id = id
        self.fromCurrency = fromCurrency
        self.toCurrency = toCurrency
        self.rate = rate
        self.date = date
    }
}
