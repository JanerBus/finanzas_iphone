import SwiftUI
import SwiftData

struct CurrenciesView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var settings: [UserSettings]
    @Query private var exchangeRates: [ExchangeRate]
    
    @State private var primaryCurrency: String = ""
    @State private var showingAddRate = false
    
    @State private var fromCurr = ""
    @State private var toCurr = ""
    @State private var rateString = ""
    
    var body: some View {
        let currentPrimary = settings.first?.primaryCurrency ?? "COP"
        
        Form {
            Section(header: Text("Moneda Principal"), footer: Text("Los totales del Inicio se calcularán y mostrarán en esta moneda.")) {
                HStack {
                    TextField("Ej. COP, USD", text: $primaryCurrency)
                        .autocapitalization(.allCharacters)
                    
                    Spacer()
                    
                    Button("Guardar") {
                        savePrimary(primaryCurrency)
                    }
                    .buttonStyle(.bordered)
                    .disabled(primaryCurrency.isEmpty || primaryCurrency == currentPrimary)
                }
            }
            
            Section(header: Text("Tasas de Cambio Manuales"), footer: Text("Estas tasas se usarán para unificar los saldos de diferentes monedas en tu Dashboard.")) {
                if exchangeRates.isEmpty {
                    Text("No hay tasas configuradas.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(exchangeRates) { rate in
                        HStack {
                            Text("1 \(rate.fromCurrency) =")
                            Spacer()
                            Text("\(rate.rate, specifier: "%.4f") \(rate.toCurrency)")
                                .fontWeight(.bold)
                        }
                    }
                    .onDelete(perform: deleteRates)
                }
                
                Button(action: {
                    showingAddRate = true
                    toCurr = currentPrimary
                }) {
                    Label("Agregar Tasa de Cambio", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Monedas y Tasas")
        .onAppear {
            primaryCurrency = currentPrimary
        }
        .sheet(isPresented: $showingAddRate) {
            NavigationStack {
                Form {
                    Section(header: Text("Nueva Tasa de Conversión")) {
                        TextField("De (Ej. USD)", text: $fromCurr).autocapitalization(.allCharacters)
                        TextField("A (Ej. COP)", text: $toCurr).autocapitalization(.allCharacters)
                        TextField("Tasa (Ej. 3950.50)", text: $rateString).keyboardType(.decimalPad)
                    }
                }
                .navigationTitle("Añadir Tasa")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) { Button("Cancelar") { showingAddRate = false } }
                    ToolbarItem(placement: .navigationBarTrailing) { Button("Guardar") { saveRate() }.fontWeight(.bold) }
                }
            }
        }
    }
    
    private func savePrimary(_ code: String) {
        let service = CurrencyService(modelContext: modelContext)
        try? service.setPrimaryCurrency(code)
    }
    
    private func saveRate() {
        let service = CurrencyService(modelContext: modelContext)
        let rateValue = Double(rateString.replacingOccurrences(of: ",", with: ".")) ?? 1.0
        try? service.saveExchangeRate(from: fromCurr, to: toCurr, rate: rateValue)
        showingAddRate = false
        fromCurr = ""
        rateString = ""
    }
    
    private func deleteRates(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(exchangeRates[index])
        }
        try? modelContext.save()
    }
}
