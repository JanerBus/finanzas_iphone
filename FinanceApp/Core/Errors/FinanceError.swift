import Foundation

public enum FinanceError: LocalizedError {
    case invalidAmount
    case sameAccountTransfer
    case insufficientData
    case genericError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidAmount: 
            return "El monto debe ser mayor a cero."
        case .sameAccountTransfer: 
            return "La cuenta de origen y destino no pueden ser la misma."
        case .insufficientData: 
            return "Faltan datos obligatorios para procesar la transacción."
        case .genericError(let message):
            return message
        }
    }
}
