import SwiftUI
import SwiftData
import UIKit

struct ShoppingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShoppingListItem.createdAt, order: .reverse) private var shoppingItems: [ShoppingListItem]
    @Query(sort: \InventoryItem.name) private var inventoryItems: [InventoryItem]
    @State private var showCovered = false
    @State private var shareText: ShareText?

    private var visibleItems: [ShoppingListItem] {
        shoppingItems.filter { showCovered || $0.quantityToBuy > 0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Toggle("Show covered items", isOn: $showCovered)
                        .tint(AppTheme.accent)
                        .padding()
                        .background(AppTheme.panel)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    actions

                    ForEach(AlcoholCategory.allCases) { category in
                        shoppingSection(category)
                    }
                }
                .padding()
            }
            .navigationTitle("Shopping List")
            .mimbyScreen()
            .sheet(item: $shareText) { item in
                ShareSheet(items: [item.text])
            }
        }
    }

    private var actions: some View {
        HStack {
            Button("Copy") {
                UIPasteboard.general.string = exportText()
            }
            .buttonStyle(SecondaryButtonStyle())

            Button("Share") {
                shareText = ShareText(text: exportText())
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    private func shoppingSection(_ category: AlcoholCategory) -> some View {
        let rows = visibleItems.filter { $0.category == category }

        return VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: category.displayName)
            if rows.isEmpty {
                EmptyStateView(title: "Nothing to buy", message: "Covered items stay hidden unless the toggle is on.")
            } else {
                ForEach(rows) { item in
                    ShoppingListRow(item: item) {
                        applyReceivedQuantity(for: item)
                    }
                }
            }
        }
    }

    private func shoppingMetric(_ label: String, _ value: Double, _ unit: UnitType, highlight: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(AppTheme.muted)
            Text("\(QuantityFormat.text(value)) \(unit.displayName)")
                .font(.subheadline.bold())
                .foregroundStyle(highlight ? AppTheme.accent : .white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func applyReceivedQuantity(for shoppingItem: ShoppingListItem) {
        let pendingQuantity = max(shoppingItem.quantityReceived - shoppingItem.quantityApplied, 0)
        guard pendingQuantity > 0 else { return }

        let inventoryItem = inventoryItemForReceiving(shoppingItem)
        let unit = inventoryUnit(for: shoppingItem.unitType, item: inventoryItem)
        unit.displayQuantity += pendingQuantity
        inventoryItem.updatedAt = .now
        shoppingItem.quantityApplied += pendingQuantity
        shoppingItem.quantityOnHand += pendingQuantity
        shoppingItem.quantityToBuy = max(shoppingItem.quantityNeeded - shoppingItem.quantityOnHand, 0)
        try? modelContext.save()
    }

    private func inventoryItemForReceiving(_ shoppingItem: ShoppingListItem) -> InventoryItem {
        if let existingItem = inventoryItems.first(where: {
            !$0.isArchived &&
            $0.name.localizedCaseInsensitiveCompare(shoppingItem.itemName) == .orderedSame &&
            $0.category == shoppingItem.category &&
            $0.tier == shoppingItem.tier
        }) {
            return existingItem
        }

        let newItem = InventoryItem(
            name: shoppingItem.itemName,
            category: shoppingItem.category,
            tier: shoppingItem.tier
        )
        newItem.units = shoppingItem.category.allowedUnits.map {
            InventoryUnit(unitType: $0, quantity: 0, item: newItem)
        }
        modelContext.insert(newItem)
        return newItem
    }

    private func inventoryUnit(for unitType: UnitType, item: InventoryItem) -> InventoryUnit {
        if let existingUnit = item.unit(for: unitType) {
            return existingUnit
        }

        let newUnit = InventoryUnit(unitType: unitType, quantity: 0, item: item)
        item.units.append(newUnit)
        return newUnit
    }

    private func exportText() -> String {
        let rows = visibleItems
        guard !rows.isEmpty else { return "Mimby Shopping List\nNothing to buy." }

        var lines = ["Mimby Shopping List"]
        for category in AlcoholCategory.allCases {
            let categoryRows = rows.filter { $0.category == category }
            guard !categoryRows.isEmpty else { continue }
            lines.append("")
            lines.append(category.displayName)
            lines += categoryRows.map {
                "- \($0.itemName): buy \(QuantityFormat.text($0.quantityToBuy)) \($0.unitType.displayName) (need \(QuantityFormat.text($0.quantityNeeded)), on hand \(QuantityFormat.text($0.quantityOnHand)))"
            }
        }
        return lines.joined(separator: "\n")
    }
}

struct ShoppingListRow: View {
    @Bindable var item: ShoppingListItem
    let onApplyReceived: () -> Void

    private var pendingQuantity: Double {
        max(item.quantityReceived - item.quantityApplied, 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.itemName).font(.headline)

            HStack {
                shoppingMetric("Need", item.quantityNeeded, item.unitType)
                shoppingMetric("On Hand", item.quantityOnHand, item.unitType)
                shoppingMetric("Buy", item.quantityToBuy, item.unitType, highlight: true)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Received")
                        .font(.subheadline.bold())
                    Spacer()
                    Text("\(QuantityFormat.text(item.quantityReceived)) of \(QuantityFormat.text(item.quantityToBuy + item.quantityApplied)) \(item.unitType.displayName)")
                        .font(.subheadline.bold())
                        .foregroundStyle(AppTheme.accent)
                }

                Stepper(value: receivedBinding, in: item.quantityApplied...(item.quantityToBuy + item.quantityApplied), step: 0.25) {
                    EmptyView()
                }
                .labelsHidden()

                if pendingQuantity > 0 {
                    Button {
                        onApplyReceived()
                    } label: {
                        Label("Add \(QuantityFormat.text(pendingQuantity)) \(item.unitType.displayName) to Inventory", systemImage: "checkmark.circle")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else if item.quantityApplied > 0 {
                    Button {} label: {
                        Label("Received Items Added", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(true)
                } else {
                    Button {} label: {
                        Label("Set Received Quantity", systemImage: "plus.forwardslash.minus")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(true)
                }
            }
            .padding()
            .background(AppTheme.panelRaised.opacity(0.65))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding()
        .background(AppTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var receivedBinding: Binding<Double> {
        Binding {
            item.quantityReceived
        } set: { newValue in
            item.quantityReceived = (newValue * 4.0).rounded() / 4.0
        }
    }

    private func shoppingMetric(_ label: String, _ value: Double, _ unit: UnitType, highlight: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(AppTheme.muted)
            Text("\(QuantityFormat.text(value)) \(unit.displayName)")
                .font(.subheadline.bold())
                .foregroundStyle(highlight ? AppTheme.accent : .white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ShareText: Identifiable {
    let id = UUID()
    let text: String
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
