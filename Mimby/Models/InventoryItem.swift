import Foundation
import SwiftData

@Model
final class InventoryItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var categoryRaw: String
    var tierRaw: String
    var isArchived: Bool
    var isEightySixed: Bool
    var lowStockThreshold: Int
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \InventoryUnit.item) var units: [InventoryUnit]

    init(
        id: UUID = UUID(),
        name: String,
        category: AlcoholCategory,
        tier: InventoryTier,
        isArchived: Bool = false,
        isEightySixed: Bool = false,
        lowStockThreshold: Int = 1,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        units: [InventoryUnit] = []
    ) {
        self.id = id
        self.name = name
        self.categoryRaw = category.rawValue
        self.tierRaw = tier.rawValue
        self.isArchived = isArchived
        self.isEightySixed = isEightySixed
        self.lowStockThreshold = lowStockThreshold
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.units = units
    }

    var category: AlcoholCategory {
        get { AlcoholCategory(rawValue: categoryRaw) ?? .beer }
        set { categoryRaw = newValue.rawValue }
    }

    var tier: InventoryTier {
        get { InventoryTier(rawValue: tierRaw) ?? .domestic }
        set { tierRaw = newValue.rawValue }
    }

    func quantity(for unitType: UnitType) -> Int {
        units.first { $0.unitType == unitType }?.quantity ?? 0
    }

    func unit(for unitType: UnitType) -> InventoryUnit? {
        units.first { $0.unitType == unitType }
    }

    var totalQuantity: Int {
        units.reduce(0) { $0 + $1.quantity }
    }
}
