import SwiftUI
import SwiftData

struct RecurringExpensesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RecurringExpense.name) private var expenses: [RecurringExpense]
    
    @State private var showingCreate = false
    
    var body: some View {
        List {
            if expenses.isEmpty {
                Text("No hay gastos recurrentes configurados.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(expenses) { expense in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(expense.name)
                                .font(.headline)
                            Spacer()
                            Text("\(expense.amount, specifier: "%.2f") \(expense.currency)")
                                .fontWeight(.bold)
                        }
                        HStack {
                            Text(expense.frequency.rawValue.capitalized)
                            Spacer()
                            Text("Próximo: \(expense.nextOccurrence, style: .date)")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("Gastos Recurrentes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCreate = true }) { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingCreate) {
            NavigationStack {
                CreateRecurringExpenseView()
            }
        }
    }
    
    private func delete(offsets: IndexSet) {
        let service = RecurringExpenseService(modelContext: modelContext)
        for index in offsets {
            do {
                try service.deleteExpense(expenses[index])
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
