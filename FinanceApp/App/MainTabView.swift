import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Inicio", systemImage: "chart.pie.fill")
                }
                .tag(0)
            
            TransactionsView()
                .tabItem {
                    Label("Movimientos", systemImage: "list.bullet.rectangle.portrait")
                }
                .tag(1)
            
            DebtsView()
                .tabItem {
                    Label("Deudas", systemImage: "person.2.fill")
                }
                .tag(2)
            
            StatisticsView()
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Configuración", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        // Color principal de la app definido en nuestro tema
        .tint(AppTheme.primaryColor)
    }
}
