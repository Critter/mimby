import Foundation
import SwiftData

@Model
final class EventRequirement {
    @Attribute(.unique) var id: UUID
    var categoryRaw: String
    var tierRaw: String
    var unitTypeRaw: String
    var quantityNeeded: Int
    var specificItem: InventoryItem?

    init(
        id: UUID = UUID(),
        category: AlcoholCategory,
        tier: InventoryTier,
        unitType: UnitType,
        quantityNeeded: Int,
        specificItem: InventoryItem? = nil
    ) {
        self.id = id
        self.categoryRaw = category.rawValue
        self.tierRaw = tier.rawValue
        self.unitTypeRaw = unitType.rawValue
        self.quantityNeeded = quantityNeeded
        self.specificItem = specificItem
    }

    var category: AlcoholCategory {
        get { AlcoholCategory(rawValue: categoryRaw) ?? .beer }
        set { categoryRaw = newValue.rawValue }
    }

    var tier: InventoryTier {
        get { InventoryTier(rawValue: tierRaw) ?? .domestic }
        set { tierRaw = newValue.rawValue }
    }

    var unitType: UnitType {
        get { UnitType(rawValue: unitTypeRaw) ?? .caseUnit }
        set { unitTypeRaw = newValue.rawValue }
    }
}

