import Foundation
import SwiftData

@MainActor
public class CurrencyService {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func setPrimaryCurrency(_ code: String) throws {
        let descriptor = FetchDescriptor<UserSettings>()
        let settingsList = (try? modelContext.fetch(descriptor)) ?? []
        
        let finalCode = code.trimmingCharacters(in: .whitespaces).uppercased()
        guard !finalCode.isEmpty else { return }
        
        if let settings = settingsList.first {
            settings.primaryCurrency = finalCode
        } else {
            let newSettings = UserSettings(primaryCurrency: finalCode)
            modelContext.insert(newSettings)
        }
        try modelContext.save()
    }
    
    public func saveExchangeRate(from: String, to: String, rate: Double) throws {
        let fromCode = from.trimmingCharacters(in: .whitespaces).uppercased()
        let toCode = to.trimmingCharacters(in: .whitespaces).uppercased()
        
        guard rate > 0 else { throw FinanceError.invalidAmount }
        
        let descriptor = FetchDescriptor<ExchangeRate>()
        let allRates = (try? modelContext.fetch(descriptor)) ?? []
        
        if let existing = allRates.first(where: { $0.fromCurrency == fromCode && $0.toCurrency == toCode }) {
            existing.rate = rate
            existing.date = Date()
        } else if let inverse = allRates.first(where: { $0.fromCurrency == toCode && $0.toCurrency == fromCode }) {
            // Actualizar la inversa
            inverse.rate = 1.0 / rate
            inverse.date = Date()
        } else {
            let newRate = ExchangeRate(fromCurrency: fromCode, toCurrency: toCode, rate: rate)
            modelContext.insert(newRate)
        }
        try modelContext.save()
    }
}
