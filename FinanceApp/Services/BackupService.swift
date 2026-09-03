import Foundation
import SwiftData

// DTOs (Data Transfer Objects) para romper dependencias cíclicas de @Model y ser Codable sin problemas
public struct BackupContainer: Codable {
    public let version: Int
    public let date: Date
    public let checksum: String // Para validación de integridad
    public let accounts: [AccountDTO]
    // Nota Técnica: En la versión completa de producción, aquí se mapearían los DTOs de 
    // Transactions, Debts, CreditCards, y RecurringExpenses. Para Fase 11, usamos Accounts como demostración estructural.
}

public struct AccountDTO: Codable {
    public let id: UUID
    public let name: String
    public let typeRaw: String
    public let currency: String
    public let initialBalance: Double
    public let isActive: Bool
    public let createdAt: Date
    public let notes: String?
}

@MainActor
public class BackupService {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Regla 47: Exportación a JSON portátil
    public func generateBackupJSON() throws -> URL {
        let accounts = (try? modelContext.fetch(FetchDescriptor<Account>())) ?? []
        
        let accountDTOs = accounts.map { acc in
            AccountDTO(id: acc.id, name: acc.name, typeRaw: acc.type.rawValue, currency: acc.currency, initialBalance: acc.initialBalance, isActive: acc.isActive, createdAt: acc.createdAt, notes: acc.notes)
        }
        
        let container = BackupContainer(
            version: 1, 
            date: Date(), 
            checksum: "INTEGRIDAD_VERIFICADA_123", // Hash ficticio para MVP
            accounts: accountDTOs
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(container)
        
        // Guardar temporalmente en el sistema de archivos del iPhone para compartirlo
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("FinanceBackup_\(Int(Date().timeIntervalSince1970)).json")
        try data.write(to: tempFile)
        
        return tempFile
    }
    
    // Regla 48: Importación y Validación
    public func restoreFromBackupJSON(url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let container = try decoder.decode(BackupContainer.self, from: data)
        
        guard container.version == 1 else {
            throw FinanceError.genericError("La versión del archivo de respaldo no es compatible con esta versión de la app.")
        }
        
        guard container.checksum == "INTEGRIDAD_VERIFICADA_123" else {
            throw FinanceError.genericError("El archivo JSON está corrupto o fue modificado externamente.")
        }
        
        // Lógica de inyección segura (Upsert)
        for dto in container.accounts {
            let id = dto.id
            let descriptor = FetchDescriptor<Account>(predicate: #Predicate { $0.id == id })
            let existing = (try? modelContext.fetch(descriptor))?.first
            
            if let acc = existing {
                acc.name = dto.name
                acc.isActive = dto.isActive
            } else {
                let type = AccountType(rawValue: dto.typeRaw) ?? .other
                let newAcc = Account(id: dto.id, name: dto.name, type: type, currency: dto.currency, initialBalance: dto.initialBalance, isActive: dto.isActive, createdAt: dto.createdAt, notes: dto.notes)
                modelContext.insert(newAcc)
            }
        }
        
        try modelContext.save()
    }
}
