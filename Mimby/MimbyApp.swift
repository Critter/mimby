import SwiftUI
import SwiftData

@main
struct MimbyApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [
            InventoryItem.self,
            InventoryUnit.self,
            EventRequirement.self,
            ShoppingListItem.self,
            InventorySnapshot.self
        ])
    }
}

