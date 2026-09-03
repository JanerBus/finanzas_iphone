import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Inicio", systemImage: "chart.pie.fill") }.tag(0)
            
            TransactionsView()
                .tabItem { Label("Movimientos", systemImage: "list.bullet.rectangle.portrait") }.tag(1)
            
            DebtsView()
                .tabItem { Label("Deudas", systemImage: "person.2.fill") }.tag(2)
            
            StatisticsView()
                .tabItem { Label("Estadísticas", systemImage: "chart.bar.fill") }.tag(3)
            
            SettingsView()
                .tabItem { Label("Configuración", systemImage: "gearshape.fill") }.tag(4)
        }
        .tint(AppTheme.primaryColor)
        .onAppear {
            seedCategoriesIfNeeded()
        }
    }
    
    // Siembrador automático de categorías requeridas en Fase 9
    private func seedCategoriesIfNeeded() {
        let descriptor = FetchDescriptor<Category>()
        let existing = (try? modelContext.fetch(descriptor)) ?? []
        if existing.isEmpty {
            let defaults = ["Alimentación", "Transporte", "Vivienda", "Salud", "Entretenimiento", "Educación", "Compras", "Ingreso Salarial"]
            for name in defaults {
                let cat = Category(name: name, icon: "tag.fill")
                modelContext.insert(cat)
            }
        }
    }
}
