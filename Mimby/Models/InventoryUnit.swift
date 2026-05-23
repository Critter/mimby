import Foundation
import SwiftData

@Model
final class InventoryUnit {
    @Attribute(.unique) var id: UUID
    var unitTypeRaw: String
    var quantity: Int
    var quantityQuarters: Int = 0
    var item: InventoryItem?

    init(id: UUID = UUID(), unitType: UnitType, quantity: Int = 0, item: InventoryItem? = nil) {
        self.id = id
        self.unitTypeRaw = unitType.rawValue
        self.quantity = quantity
        self.item = item
    }

    var unitType: UnitType {
        get { UnitType(rawValue: unitTypeRaw) ?? .bottle }
        set { unitTypeRaw = newValue.rawValue }
    }

    var displayQuantity: Double {
        get {
            quantityQuarters > 0 ? Double(quantityQuarters) / 4.0 : Double(quantity)
        }
        set {
            let quarters = Int((max(newValue, 0) * 4.0).rounded())
            quantityQuarters = quarters
            quantity = quarters / 4
        }
    }
}
