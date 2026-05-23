import Foundation

struct DashboardViewModel {
    let items: [InventoryItem]

    func total(category: AlcoholCategory, tier: InventoryTier) -> Double {
        items
            .filter { !$0.isArchived && !$0.isEightySixed && $0.category == category && $0.tier == tier }
            .flatMap(\.units)
            .reduce(0) { $0 + $1.displayQuantity }
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
