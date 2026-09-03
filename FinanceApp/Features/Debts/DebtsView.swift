import SwiftUI

struct DebtsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Por Cobrar / Por Pagar")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Deudas")
        }
    }
}
