import Foundation
import Observation
import SwiftData

@Observable
final class EventBuilderViewModel {
    var selectedCategory: AlcoholCategory = .beer {
        didSet {
            selectedTier = selectedCategory.tiers.first ?? .domestic
            selectedUnit = selectedCategory.allowedUnits.first ?? .caseUnit
            specificItemID = nil
        }
    }
    var selectedTier: InventoryTier = .domestic
    var selectedUnit: UnitType = .caseUnit
    var quantityNeeded: Int = 1
    var useSpecificItem = false
    var specificItemID: UUID?

    func addRequirement(context: ModelContext, inventory: [InventoryItem]) {
        let selectedItem = inventory.first { $0.id == specificItemID }
        let requirement = EventRequirement(
            category: selectedCategory,
            tier: selectedTier,
            unitType: selectedUnit,
            quantityNeeded: max(quantityNeeded, 0),
            specificItem: useSpecificItem ? selectedItem : nil
        )
        context.insert(requirement)
        quantityNeeded = 1
        specificItemID = nil
        useSpecificItem = false
    }
}
