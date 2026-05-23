import Foundation
import SwiftData

enum InventorySampleData {
    static func seedIfNeeded(context: ModelContext, existingItems: [InventoryItem]) {
        guard existingItems.isEmpty else { return }

        let samples: [(String, AlcoholCategory, InventoryTier)] = [
            ("Michelob Ultra", .beer, .domestic),
            ("Bud Light", .beer, .domestic),
            ("Stella", .beer, .importTier),
            ("Local IPA", .beer, .craft),
            ("House Chardonnay", .wine, .house),
            ("Josh Chardonnay", .wine, .mid),
            ("Premium Cabernet", .wine, .premium),
            ("Tito's", .liquor, .house),
            ("House Gin", .liquor, .house),
            ("Mid Gin", .liquor, .mid),
            ("Premium Bourbon", .liquor, .premium)
        ]

        for sample in samples {
            let item = InventoryItem(name: sample.0, category: sample.1, tier: sample.2)
            item.units = sample.1.allowedUnits.map { InventoryUnit(unitType: $0, quantity: 0, item: item) }
            context.insert(item)
        }
    }
}
