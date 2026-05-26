import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var inventory: [InventoryItem]
    @Query private var requirements: [EventRequirement]
    @Query private var shoppingItems: [ShoppingListItem]
    @Query private var snapshots: [InventorySnapshot]
    @State private var showSoftReset = false
    @State private var showSoftResetComplete = false
    @State private var showFullReset = false
    @State private var showRecount = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Inventory Management")

                    Button("Soft Reset Inventory") {
                        showSoftReset = true
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Button("Start Fresh From Recount") {
                        softResetInventory(showCompletion: false)
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
            .alert("Soft Reset Complete", isPresented: $showSoftResetComplete) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Inventory quantities, event requirements, and shopping list items were cleared. Products and settings were kept.")
            }
            .confirmationDialog(
                "Clear inventory quantities, event requirements, and shopping list items? Product names, categories, tiers, and settings will stay.",
                isPresented: $showSoftReset,
                titleVisibility: .visible
            ) {
                Button("Soft Reset", role: .destructive) {
                    softResetInventory(showCompletion: true)
                }
                Button("Cancel", role: .cancel) {}
            }
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

    private func softResetInventory(showCompletion: Bool) {
        for item in inventory {
            for unit in item.units {
                unit.displayQuantity = 0
            }
            item.updatedAt = .now
        }

        requirements.forEach { modelContext.delete($0) }
        shoppingItems.forEach { modelContext.delete($0) }
        try? modelContext.save()

        if showCompletion {
            showSoftResetComplete = true
        }
    }

    private func fullReset() {
        inventory.forEach { modelContext.delete($0) }
        requirements.forEach { modelContext.delete($0) }
        shoppingItems.forEach { modelContext.delete($0) }
        snapshots.forEach { modelContext.delete($0) }
        try? modelContext.save()
    }
}
