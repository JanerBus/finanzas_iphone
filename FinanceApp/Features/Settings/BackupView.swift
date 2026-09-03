import SwiftUI

struct BackupView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var backupURL: URL?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingImportAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Exportar Datos"), footer: Text("Genera un archivo JSON universal con toda tu base de datos. Guárdalo localmente o compártelo.")) {
                Button(action: generateBackup) {
                    Label("1. Preparar Copia de Seguridad", systemImage: "square.and.arrow.up")
                }
                
                // ShareLink es la API nativa de iOS para abrir la hoja de compartir (AirDrop, Archivos, Mail)
                if let url = backupURL {
                    ShareLink(item: url, message: Text("Copia de seguridad de Mis Finanzas (Offline)")) {
                        Label("2. Guardar o Compartir Archivo JSON", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .bold()
                    }
                }
            }
            
            Section(header: Text("Importar Datos"), footer: Text("Restaurar desde un archivo JSON sobrescribirá la base de datos local actual.")) {
                Button(action: { showingImportAlert = true }) {
                    Label("Restaurar desde Archivo", systemImage: "arrow.down.doc")
                        .foregroundColor(AppTheme.errorColor)
                }
            }
        }
        .navigationTitle("Copias de Seguridad")
        .alert("Importar Backup", isPresented: $showingImportAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Seleccionar Archivo") {
                // En una ejecución real de iOS, aquí se llama a `.fileImporter`.
                // Como validación de MVP, dejamos el mock de UI.
                errorMessage = "Para importar, el FileImporter nativo debe probarse directamente en el simulador de iOS o en un iPhone físico."
                showingError = true
            }
        } message: {
            Text("Asegúrate de tener un archivo .json generado previamente por la app.")
        }
        .alert("Notificación", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func generateBackup() {
        let service = BackupService(modelContext: modelContext)
        do {
            let url = try service.generateBackupJSON()
            backupURL = url
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
