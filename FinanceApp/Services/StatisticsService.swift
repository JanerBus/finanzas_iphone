import Foundation
import SwiftData

public struct CategoryExpense: Identifiable {
    public let id = UUID()
    public let categoryName: String
    public let amount: Double
}

public struct MonthlySummary: Identifiable {
    public let id = UUID()
    public let monthDate: Date
    public let income: Double
    public let expense: Double
}

@MainActor
public class StatisticsService {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func expensesByCategory(for month: Date) -> [CategoryExpense] {
        let (start, end) = monthRange(for: month)
        let txs = (try? modelContext.fetch(FetchDescriptor<Transaction>())) ?? []
        
        let expenses = txs.filter { ($0.type == .expense || $0.type == .creditCardPurchase) && $0.date >= start && $0.date <= end }
        
        var grouped: [String: Double] = [:]
        for tx in expenses {
            let catName = tx.category?.name ?? "Sin Categoría"
            grouped[catName, default: 0.0] += tx.amount
        }
        
        return grouped.map { CategoryExpense(categoryName: $0.key, amount: $0.value) }
                      .sorted { $0.amount > $1.amount }
    }
    
    public func lastSixMonthsSummary() -> [MonthlySummary] {
        var summaries: [MonthlySummary] = []
        let calendar = Calendar.current
        
        let txs = (try? modelContext.fetch(FetchDescriptor<Transaction>())) ?? []
        let today = Date()
        
        for i in (0..<6).reversed() {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: today) else { continue }
            let (start, end) = monthRange(for: monthDate)
            
            let monthTxs = txs.filter { $0.date >= start && $0.date <= end }
            let income = monthTxs.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            let expense = monthTxs.filter { $0.type == .expense || $0.type == .creditCardPurchase }.reduce(0) { $0 + $1.amount }
            
            // Usamos el 1er día del mes para graficar limpiamente
            let displayDate = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))!
            summaries.append(MonthlySummary(monthDate: displayDate, income: income, expense: expense))
        }
        
        return summaries
    }
    
    private func monthRange(for date: Date) -> (Date, Date) {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let end = calendar.date(byAdding: DateComponents(month: 1, second: -1), to: start)!
        return (start, end)
    }
}
