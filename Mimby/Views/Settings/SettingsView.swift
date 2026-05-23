import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var inventory: [InventoryItem]
    @Query private var requirements: [EventRequirement]
    @Query private var shoppingItems: [ShoppingListItem]
    @Query private var snapshots: [InventorySnapshot]
    @State private var showFullReset = false
    @State private var showRecount = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Inventory Management")

                    Button("Soft Reset Inventory") {
                        for item in inventory {
                            for unit in item.units { unit.quantity = 0 }
                            item.updatedAt = .now
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("Start Fresh From Recount") {
                        for item in inventory {
                            for unit in item.units { unit.quantity = 0 }
                            item.updatedAt = .now
                        }
                        showRecount = true
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button(role: .destructive) {
                        showFullReset = true
                    } label: {
                        Text("Full Reset Inventory")
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Text("Mimby tracks what is currently on hand after manual counts. It does not track sales, pour activity, or automatic depletion during an event.")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.muted)
                        .padding()
                        .background(AppTheme.panel)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .padding()
            }
            .navigationTitle("Settings")
            .mimbyScreen()
            .sheet(isPresented: $showRecount) { RecountView() }
            .confirmationDialog(
                "This deletes all products, event requirements, shopping lists, and snapshots.",
                isPresented: $showFullReset,
                titleVisibility: .visible
            ) {
                Button("Delete Everything", role: .destructive, action: fullReset)
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func fullReset() {
        inventory.forEach { modelContext.delete($0) }
        requirements.forEach { modelContext.delete($0) }
        shoppingItems.forEach { modelContext.delete($0) }
        snapshots.forEach { modelContext.delete($0) }
    }
}

