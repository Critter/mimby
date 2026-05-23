import SwiftUI
import SwiftData

struct InventoryItemEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name: String
    @State private var category: AlcoholCategory
    @State private var tier: InventoryTier
    @State private var isArchived: Bool
    @State private var selectedUnitType: UnitType
    @State private var quantities: [UnitType: Int]
    @State private var showDeleteConfirmation = false

    private let item: InventoryItem?

    init(item: InventoryItem? = nil) {
        self.item = item
        _name = State(initialValue: item?.name ?? "")
        _category = State(initialValue: item?.category ?? .beer)
        _tier = State(initialValue: item?.tier ?? .domestic)
        _isArchived = State(initialValue: item?.isArchived ?? false)
        let initialCategory = item?.category ?? .beer
        _selectedUnitType = State(initialValue: initialCategory.allowedUnits.first ?? .caseUnit)
        _quantities = State(initialValue: Dictionary(uniqueKeysWithValues: initialCategory.allowedUnits.map { unitType in
            (unitType, item?.quantity(for: unitType) ?? 0)
        }))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Product") {
                    TextField("Item name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(AlcoholCategory.allCases) { Text($0.displayName).tag($0) }
                    }
                    Picker("Tier", selection: $tier) {
                        ForEach(category.tiers) { Text($0.displayName).tag($0) }
                    }
                    Toggle("Archived", isOn: $isArchived)
                }

                Section("Quantities") {
                    FlowLayout(spacing: 8) {
                        ForEach(category.allowedUnits) { unitType in
                            Button {
                                selectedUnitType = unitType
                            } label: {
                                Text("\(quantities[unitType, default: 0]) \(unitType.displayName)")
                                    .font(.subheadline.bold())
                                    .padding(.horizontal, 12)
                                    .frame(minHeight: 40)
                                    .background(selectedUnitType == unitType ? AppTheme.accent : AppTheme.panelRaised)
                                    .foregroundStyle(selectedUnitType == unitType ? .black : .white)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(selectedUnitType.displayName)
                            .font(.headline)

                        HStack(spacing: 14) {
                            Button {
                                quantities[selectedUnitType] = max(quantities[selectedUnitType, default: 0] - 1, 0)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 38))
                            }
                            .accessibilityLabel("Decrease \(selectedUnitType.displayName)")

                            TextField("Quantity", value: quantityBinding(for: selectedUnitType), format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 34, weight: .bold))
                                .frame(maxWidth: .infinity, minHeight: 54)
                                .background(AppTheme.panelRaised)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                            Button {
                                quantities[selectedUnitType, default: 0] += 1
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 38))
                            }
                            .accessibilityLabel("Increase \(selectedUnitType.displayName)")
                        }
                        .tint(AppTheme.accent)
                    }
                    .padding(.vertical, 8)
                }

                if item != nil {
                    Section {
                        Button("Delete Item", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle(item == nil ? "Add Inventory" : "Edit Inventory")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: category) {
                if !category.tiers.contains(tier) {
                    tier = category.tiers.first ?? .domestic
                }
                refreshQuantityUnits()
            }
            .confirmationDialog(
                "Delete this inventory item and its quantities?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Item", role: .destructive) {
                    if let item {
                        modelContext.delete(item)
                    }
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let item {
            item.name = trimmedName
            item.category = category
            item.tier = tier
            item.isArchived = isArchived
            item.updatedAt = .now
            ensureUnits(for: item)
            applyQuantities(to: item)
        } else {
            let newItem = InventoryItem(name: trimmedName, category: category, tier: tier, isArchived: isArchived)
            newItem.units = category.allowedUnits.map {
                InventoryUnit(unitType: $0, quantity: quantities[$0, default: 0], item: newItem)
            }
            modelContext.insert(newItem)
        }

        dismiss()
    }

    private func ensureUnits(for item: InventoryItem) {
        let allowed = Set(category.allowedUnits.map(\.rawValue))
        item.units.removeAll { !allowed.contains($0.unitTypeRaw) }

        for unitType in category.allowedUnits where item.unit(for: unitType) == nil {
            item.units.append(InventoryUnit(unitType: unitType, quantity: 0, item: item))
        }
    }

    private func applyQuantities(to item: InventoryItem) {
        for unitType in category.allowedUnits {
            item.unit(for: unitType)?.quantity = quantities[unitType, default: 0]
        }
    }

    private func refreshQuantityUnits() {
        let allowedUnits = category.allowedUnits
        quantities = Dictionary(uniqueKeysWithValues: allowedUnits.map { unitType in
            (unitType, quantities[unitType, default: item?.quantity(for: unitType) ?? 0])
        })

        if !allowedUnits.contains(selectedUnitType) {
            selectedUnitType = allowedUnits.first ?? .bottle
        }
    }

    private func quantityBinding(for unitType: UnitType) -> Binding<Int> {
        Binding {
            quantities[unitType, default: 0]
        } set: { newValue in
            quantities[unitType] = max(newValue, 0)
        }
    }
}
