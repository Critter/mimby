import Foundation

enum ShoppingListCalculator {
    static func calculate(requirements: [EventRequirement], inventory: [InventoryItem]) -> [ShoppingListItem] {
        requirements.map { requirement in
            let onHand: Int
            let displayName: String

            if let item = requirement.specificItem {
                onHand = item.isArchived || item.isEightySixed ? 0 : item.quantity(for: requirement.unitType)
                displayName = item.name
            } else {
                let matchingItems = inventory.filter {
                    !$0.isArchived &&
                    !$0.isEightySixed &&
                    $0.category == requirement.category &&
                    $0.tier == requirement.tier
                }
                onHand = matchingItems.reduce(0) { $0 + $1.quantity(for: requirement.unitType) }
                displayName = "\(requirement.tier.displayName) \(requirement.category.displayName)"
            }

            return ShoppingListItem(
                itemName: displayName,
                category: requirement.category,
                tier: requirement.tier,
                unitType: requirement.unitType,
                quantityNeeded: requirement.quantityNeeded,
                quantityOnHand: onHand,
                quantityToBuy: max(requirement.quantityNeeded - onHand, 0)
            )
        }
    }
}

