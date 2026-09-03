# BalanceApp - Finanzas Personales Offline para iOS

Una aplicación nativa de iOS diseñada para gestionar finanzas personales con un enfoque estricto en la contabilidad real (saldos derivados), protección del patrimonio, privacidad de datos (100% offline con SwiftData), y soporte multimoneda.

## 🚀 Características Principales

- **Privacidad Absoluta (Offline-First)**: Los datos viven en tu dispositivo mediante `SwiftData`. No hay servidores de terceros, cuentas en la nube ni bases de datos externas.
- **Arquitectura Contable Estricta (Event Sourcing)**: El saldo de tus cuentas no es una variable editable. Se calcula dinámicamente sumando todos los movimientos históricos (`LedgerEntries`), garantizando cero descuadres.
- **Separación de Patrimonio vs Liquidez**: 
  - *Préstamos*: Prestar dinero disminuye tu liquidez pero no tu patrimonio (pasa a ser una cuenta por cobrar).
  - *Tarjetas de Crédito*: Pagar una cuota descuenta dinero de tu banco pero no se contabiliza como un nuevo gasto (el gasto ocurrió al momento de la compra).
- **Módulo de Deudas**: Control total sobre quién te debe y a quién le debes, con historial de pagos parciales.
- **Multimoneda Inteligente**: Puedes tener cuentas en COP, billeteras en USD y deudas en EUR. El Dashboard consolidará todo tu patrimonio en una única moneda base configurada, utilizando tasas de conversión definidas por ti.
- **Dashboard Estadístico**: Gráficas nativas (`SwiftUI Charts`) que dividen tus gastos mensuales por categoría e histórico semestral de ingresos vs egresos.
- **Copias de Seguridad (Backup JSON)**: Exporta toda tu base de datos a un formato JSON universal y portátil que puedes guardar en iCloud, enviarte por correo o restaurar más adelante.

## 🛠 Arquitectura y Tecnologías

El proyecto fue construido utilizando los últimos estándares de Apple:
- **Lenguaje**: Swift 5.9+
- **Interfaz**: SwiftUI (iOS 17+)
- **Base de Datos**: SwiftData (Modelos persistentes nativos)
- **Patrón de Diseño**: MVVM (Model-View-ViewModel) con capa de Servicios (`Service Layer`). Las vistas solo observan datos (`@Query`) y delegan acciones complejas a los servicios para mantener la UI limpia.

## 📁 Estructura del Proyecto

```text
FinanceApp/
├── App/                # Punto de entrada y Tema de la aplicación
├── Data/
│   └── Models/         # Esquemas de SwiftData (@Model)
├── Services/           # Lógica de negocio (Transaction, Debt, Balance, Backup)
└── Features/           # Módulos visuales segmentados
    ├── Dashboard/      # Pantalla principal e indicadores globales
    ├── Accounts/       # Cuentas bancarias y efectivo
    ├── Transactions/   # Gastos, Ingresos y Transferencias
    ├── Debts/          # Préstamos a favor y deudas a terceros
    ├── CreditCards/    # Tarjetas, compras en cuotas y abonos
    ├── Recurring/      # Gastos automáticos recurrentes
    ├── Statistics/     # Gráficas nativas
    └── Settings/       # Configuración multimoneda y Backup JSON
```

## 📚 Reglas de Negocio Implementadas

1. **Transferencias propias**: Mover dinero entre cuentas no afecta el patrimonio ni se cuenta como gasto.
2. **Compras con Tarjeta**: Afectan tu saldo utilizado en tarjeta inmediatamente y se marcan como "Gasto del mes", pero no tocan el dinero de tus cuentas bancarias.
3. **Pagos de Tarjeta**: Saca el dinero de tu banco para saldar la deuda, pero no se registra como "Gasto", evitando la duplicación contable.
4. **Suscripciones**: Los gastos recurrentes *no* se cobran solos. Se encolan en el Dashboard esperando tu autorización manual ("Omitir" o "Registrar") para evitar desastres contables por olvido.

## 💻 Instalación y Compilación

Dado que es un proyecto nativo de iOS, requieres entorno Apple para compilar:
1. Clona el repositorio: `git clone https://github.com/JanerBus/finanzas_iphone.git`
2. Abre la carpeta raíz en **Xcode 15** (o superior).
3. Selecciona tu simulador (ej. iPhone 15 Pro) o tu dispositivo físico conectado.
4. Presiona `Cmd + R` para compilar y ejecutar.

---
*Desarrollado bajo principios de Código Limpio y Arquitectura Mantenible.*
