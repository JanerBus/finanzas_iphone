import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Configuración")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Configuración")
        }
    }
}
