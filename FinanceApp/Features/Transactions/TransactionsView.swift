import SwiftUI

struct TransactionsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Historial de Movimientos")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Movimientos")
        }
    }
}
