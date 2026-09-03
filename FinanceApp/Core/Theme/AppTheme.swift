import SwiftUI

public struct AppTheme {
    // Definimos los colores principales de la aplicación para mantener consistencia.
    // La app soportará nativamente Light y Dark mode usando colores del sistema cuando sea posible.
    
    public static let primaryColor = Color.blue
    public static let successColor = Color.green
    public static let errorColor = Color.red
    public static let warningColor = Color.orange
    
    // Un color de fondo secundario útil para tarjetas o agrupaciones
    public static let backgroundSecondary = Color(UIColor.secondarySystemBackground)
}
