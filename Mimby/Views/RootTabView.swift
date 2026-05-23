import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InventoryItem.name) private var inventoryItems: [InventoryItem]

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "gauge.with.dots.needle.50percent") }

            InventoryView()
                .tabItem { Label("Inventory", systemImage: "shippingbox") }

            EventBuilderView()
                .tabItem { Label("Event", systemImage: "list.bullet.clipboard") }

            ShoppingListView()
                .tabItem { Label("Shopping", systemImage: "cart") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(AppTheme.accent)
        .task {
            InventorySampleData.seedIfNeeded(context: modelContext, existingItems: inventoryItems)
        }
    }
}

