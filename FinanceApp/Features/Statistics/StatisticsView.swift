import SwiftUI
import SwiftData
import Charts // Requiere iOS 16+

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Se usa @Query para reaccionar a cambios, aunque la lógica esté en el Service
    @Query private var transactions: [Transaction] 
    
    @State private var selectedMonth = Date()
    
    var body: some View {
        let service = StatisticsService(modelContext: modelContext)
        let expensesByCategory = service.expensesByCategory(for: selectedMonth)
        let sixMonths = service.lastSixMonthsSummary()
        
        NavigationStack {
            List {
                Section(header: Text("Gastos por Categoría (Este Mes)")) {
                    if expensesByCategory.isEmpty {
                        Text("No hay gastos registrados este mes.")
                            .foregroundColor(.secondary)
                    } else {
                        // Gráfico de pastel disponible en SwiftUI Charts desde iOS 17+
                        Chart(expensesByCategory) { item in
                            SectorMark(
                                angle: .value("Monto", item.amount),
                                innerRadius: .ratio(0.5),
                                angularInset: 1.5
                            )
                            .foregroundStyle(by: .value("Categoría", item.categoryName))
                        }
                        .frame(height: 250)
                        .padding()
                        
                        // Lista con detalle
                        ForEach(expensesByCategory) { item in
                            HStack {
                                Text(item.categoryName)
                                Spacer()
                                Text("\(item.amount, specifier: "%.2f")")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section(header: Text("Ingresos vs Gastos (Últimos 6 meses)")) {
                    Chart(sixMonths) { summary in
                        // Barras agrupadas por mes y divididas por tipo
                        BarMark(
                            x: .value("Mes", summary.monthDate, unit: .month),
                            y: .value("Monto", summary.income)
                        )
                        .foregroundStyle(AppTheme.successColor)
                        .position(by: .value("Tipo", "Ingreso"))
                        
                        BarMark(
                            x: .value("Mes", summary.monthDate, unit: .month),
                            y: .value("Monto", summary.expense)
                        )
                        .foregroundStyle(AppTheme.errorColor)
                        .position(by: .value("Tipo", "Gasto"))
                    }
                    .frame(height: 250)
                    .padding(.vertical)
                }
            }
            .navigationTitle("Estadísticas")
        }
    }
}
