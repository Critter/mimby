import Foundation
import SwiftData

@Model
final class ShoppingListItem {
    @Attribute(.unique) var id: UUID
    var itemName: String
    var categoryRaw: String
    var tierRaw: String
    var unitTypeRaw: String
    var quantityNeeded: Int
    var quantityOnHand: Int
    var quantityToBuy: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        itemName: String,
        category: AlcoholCategory,
        tier: InventoryTier,
        unitType: UnitType,
        quantityNeeded: Int,
        quantityOnHand: Int,
        quantityToBuy: Int,
        createdAt: Date = .now
    ) {
        self.id = id
        self.itemName = itemName
        self.categoryRaw = category.rawValue
        self.tierRaw = tier.rawValue
        self.unitTypeRaw = unitType.rawValue
        self.quantityNeeded = quantityNeeded
        self.quantityOnHand = quantityOnHand
        self.quantityToBuy = quantityToBuy
        self.createdAt = createdAt
    }

    var category: AlcoholCategory { AlcoholCategory(rawValue: categoryRaw) ?? .beer }
    var tier: InventoryTier { InventoryTier(rawValue: tierRaw) ?? .domestic }
    var unitType: UnitType { UnitType(rawValue: unitTypeRaw) ?? .caseUnit }
}

