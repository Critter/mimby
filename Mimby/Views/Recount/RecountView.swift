import SwiftUI
import SwiftData

struct RecountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InventoryItem.name) private var inventory: [InventoryItem]
    @State private var eventName = ""
    @State private var notes = ""

    private var activeInventory: [InventoryItem] {
        inventory.filter { !$0.isArchived }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        TextField("Event name", text: $eventName)
                        TextField("Notes", text: $notes, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    .textFieldStyle(.roundedBorder)

                    ForEach(AlcoholCategory.allCases) { category in
                        categoryRecount(category)
                    }

                    Button("Save Recount") {
                        saveSnapshot()
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
            }
            .navigationTitle("End of Night")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .mimbyScreen()
        }
    }

    private func categoryRecount(_ category: AlcoholCategory) -> some View {
        let categoryItems = activeInventory.filter { $0.category == category }

        return VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: category.displayName)
            ForEach(category.tiers) { tier in
                let tierItems = categoryItems.filter { $0.tier == tier }
                if !tierItems.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(tier.displayName)
                            .font(.headline)
                            .foregroundStyle(AppTheme.accent)
                        ForEach(tierItems) { item in
                            RecountItemRow(item: item)
                        }
                    }
                    .padding()
                    .background(AppTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }

    private func saveSnapshot() {
        let name = eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Recount \(Date.now.formatted(date: .abbreviated, time: .shortened))"
            : eventName

        let summary = activeInventory.map { item in
            let units = item.units
                .sorted { $0.unitType.displayName < $1.unitType.displayName }
                .map { "\($0.quantity) \($0.unitType.displayName)" }
                .joined(separator: ", ")
            return "\(item.name) [\(item.category.displayName) / \(item.tier.displayName)]: \(units)"
        }
        .joined(separator: "\n")

        for item in activeInventory {
            item.updatedAt = .now
        }

        modelContext.insert(InventorySnapshot(name: name, notes: notes, serializedInventorySummary: summary))
    }
}

struct RecountItemRow: View {
    @Bindable var item: InventoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.name)
                .font(.headline)
            ForEach(item.units.sorted { $0.unitType.displayName < $1.unitType.displayName }) { unit in
                RecountUnitStepper(unit: unit)
            }
        }
        .padding()
        .background(AppTheme.panelRaised.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct RecountUnitStepper: View {
    @Bindable var unit: InventoryUnit

    var body: some View {
        Stepper(value: $unit.quantity, in: 0...999) {
            HStack {
                Text(unit.unitType.displayName)
                Spacer()
                Text("\(unit.quantity)")
                    .font(.headline)
                    .foregroundStyle(AppTheme.accent)
            }
        }
    }
}

