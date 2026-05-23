import Foundation

struct DashboardViewModel {
    let items: [InventoryItem]

    func activeItems(category: AlcoholCategory, tier: InventoryTier) -> [InventoryItem] {
        items.filter {
            !$0.isArchived &&
            !$0.isEightySixed &&
            $0.category == category &&
            $0.tier == tier
        }
    }

    func total(category: AlcoholCategory, tier: InventoryTier) -> Double {
        activeItems(category: category, tier: tier)
            .flatMap(\.units)
            .reduce(0) { $0 + $1.displayQuantity }
    }

    func unitTotals(category: AlcoholCategory, tier: InventoryTier) -> [(UnitType, Double)] {
        category.allowedUnits.compactMap { unitType in
            let total = activeItems(category: category, tier: tier)
                .reduce(0) { $0 + $1.quantity(for: unitType) }
            return total > 0 ? (unitType, total) : nil
        }
    }

    func nonZeroUnits(for item: InventoryItem) -> [InventoryUnit] {
        item.units
            .filter { $0.displayQuantity > 0 }
            .sorted { $0.unitType.displayName < $1.unitType.displayName }
    }

    var lowStockItems: [InventoryItem] {
        items.filter { item in
            !item.isArchived && !item.isEightySixed && item.totalQuantity <= Double(item.lowStockThreshold)
        }
    }

    var eightySixedItems: [InventoryItem] {
        items.filter { !$0.isArchived && $0.isEightySixed }
    }
}
