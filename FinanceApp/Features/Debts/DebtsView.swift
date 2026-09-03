import SwiftUI
import SwiftData

struct DebtsView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Tipo", selection: $selectedTab) {
                    Text("Me Deben").tag(0)
                    Text("Yo Debo").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    DebtsListView(direction: .receivable)
                } else {
                    DebtsListView(direction: .payable)
                }
            }
            .navigationTitle("Deudas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CreateDebtView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct DebtsListView: View {
    let direction: DebtDirection
    @Query private var allDebts: [Debt]
    
    var filteredDebts: [Debt] {
        allDebts.filter { $0.direction == direction && $0.status != .paid && $0.status != .cancelled }
    }
    
    var body: some View {
        List {
            if filteredDebts.isEmpty {
                Text("No hay deudas pendientes en esta categoría.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(filteredDebts) { debt in
                    NavigationLink(destination: DebtDetailView(debt: debt)) {
                        DebtRowView(debt: debt)
                    }
                }
            }
        }
    }
}

struct DebtRowView: View {
    let debt: Debt
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(debt.person?.name ?? "Desconocido")
                    .font(.headline)
                Text(debt.desc ?? "Sin descripción")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(debt.remainingAmount, specifier: "%.2f") \(debt.currency)")
                    .fontWeight(.semibold)
                    .foregroundColor(debt.direction == .receivable ? AppTheme.successColor : AppTheme.errorColor)
                Text(debt.status.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}
