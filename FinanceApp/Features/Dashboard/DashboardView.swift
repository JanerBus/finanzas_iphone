import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Dashboard Financiero")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Inicio")
        }
    }
}
