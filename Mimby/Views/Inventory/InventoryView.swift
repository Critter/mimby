import SwiftUI
import SwiftData

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InventoryItem.name) private var items: [InventoryItem]
    @State private var showEditor = false
    @State private var editingItem: InventoryItem?

    var body: some View {
        NavigationStack {
            List {
                ForEach(AlcoholCategory.allCases) { category in
                    categoryHeader(category)

                    ForEach(category.tiers) { tier in
                        tierHeader(tier)

                        let tierItems = items.filter { !$0.isArchived && $0.category == category && $0.tier == tier }
                        if tierItems.isEmpty {
                            emptyTierRow()
                        } else {
                            ForEach(tierItems) { item in
                                InventoryItemRow(item: item) { editingItem = item }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            modelContext.delete(item)
                                            try? modelContext.save()
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(AppTheme.background)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showEditor = true } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("Add Inventory")
                }
            }
            .mimbyScreen()
            .sheet(isPresented: $showEditor) { InventoryItemEditorView() }
            .sheet(item: $editingItem) { item in
                InventoryItemEditorView(item: item)
            }
        }
    }

    private func categoryHeader(_ category: AlcoholCategory) -> some View {
        Text(category.displayName)
            .font(.title3.bold())
            .foregroundStyle(.white)
            .padding(.top, 14)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(AppTheme.background)
    }

    private func tierHeader(_ tier: InventoryTier) -> some View {
        Text(tier.displayName)
            .font(.headline)
            .foregroundStyle(AppTheme.accent)
            .padding(.top, 8)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(AppTheme.background)
    }

    private func emptyTierRow() -> some View {
        Text("No active items")
            .font(.subheadline)
            .foregroundStyle(AppTheme.muted)
            .padding(.vertical, 8)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(AppTheme.background)
    }
}

struct InventoryItemRow: View {
    @Bindable var item: InventoryItem
    @State private var selectedUnit: InventoryUnit?
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("\(item.category.displayName) • \(item.tier.displayName)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.muted)
                }
                Spacer()
                VStack(spacing: 4) {
                    Toggle("86'd", isOn: $item.isEightySixed)
                        .labelsHidden()
                        .tint(AppTheme.danger)
                    Text("86'd")
                        .font(.caption2.bold())
                        .foregroundStyle(item.isEightySixed ? AppTheme.danger : AppTheme.muted)
                }
                Button(action: onEdit) {
                    Image(systemName: "square.and.pencil")
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Edit \(item.name)")
            }

            FlowLayout(spacing: 8) {
                ForEach(item.units.sorted { $0.unitType.displayName < $1.unitType.displayName }) { unit in
                    Button {
                        selectedUnit = unit
                    } label: {
                        Text("\(unit.quantity) \(unit.unitType.displayName)")
                            .font(.subheadline.bold())
                            .padding(.horizontal, 12)
                            .frame(minHeight: 38)
                            .background(AppTheme.panelRaised)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.panelRaised.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .sheet(item: $selectedUnit) { unit in
            QuantityEditorView(unit: unit)
                .presentationDetents([.height(280)])
        }
    }
}
