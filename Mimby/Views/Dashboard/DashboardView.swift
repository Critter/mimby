import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \InventoryItem.name) private var items: [InventoryItem]
    @State private var showAddInventory = false
    @State private var showRecount = false
    @State private var expandedTiers: Set<String> = []

    private var viewModel: DashboardViewModel { DashboardViewModel(items: items) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    quickActions
                    totalsSection
                    statusSection(title: "Low Stock", items: viewModel.lowStockItems)
                    statusSection(title: "86'd Items", items: viewModel.eightySixedItems)
                }
                .padding()
            }
            .navigationTitle("Mimby")
            .mimbyScreen()
            .sheet(isPresented: $showAddInventory) { InventoryItemEditorView() }
            .sheet(isPresented: $showRecount) { RecountView() }
        }
    }

    private var quickActions: some View {
        VStack(spacing: 10) {
            Button("Add Inventory") { showAddInventory = true }.buttonStyle(PrimaryButtonStyle())
            NavigationLink("Build Event") { EventBuilderView() }.buttonStyle(SecondaryButtonStyle())
            Button("Start Recount") { showRecount = true }.buttonStyle(SecondaryButtonStyle())
        }
    }

    private var totalsSection: some View {
        VStack(spacing: 14) {
            ForEach(AlcoholCategory.allCases) { category in
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: category.displayName)
                    ForEach(category.tiers) { tier in
                        inventorySummaryCard(category: category, tier: tier)
                    }
                }
            }
        }
    }

    private func inventorySummaryCard(category: AlcoholCategory, tier: InventoryTier) -> some View {
        let key = expansionKey(category: category, tier: tier)
        let isExpanded = expandedTiers.contains(key)
        let unitTotals = viewModel.unitTotals(category: category, tier: tier)
        let tierItems = viewModel.activeItems(category: category, tier: tier)

        return VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.snappy) {
                    if isExpanded {
                        expandedTiers.remove(key)
                    } else {
                        expandedTiers.insert(key)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(tier.displayName)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(unitTotalsSummary(unitTotals))
                            .font(.subheadline.bold())
                            .foregroundStyle(unitTotals.isEmpty ? AppTheme.muted : AppTheme.accent)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.accent)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                if tierItems.isEmpty {
                    Text("No counted stock")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.muted)
                        .padding(.vertical, 6)
                } else {
                    VStack(spacing: 10) {
                        ForEach(tierItems) { item in
                            dashboardItemBreakdown(item)
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func dashboardItemBreakdown(_ item: InventoryItem) -> some View {
        let units = viewModel.nonZeroUnits(for: item)

        return HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                if units.isEmpty {
                    Text("No counted stock")
                        .font(.caption)
                        .foregroundStyle(AppTheme.muted)
                } else {
                    FlowLayout(spacing: 6) {
                        ForEach(units) { unit in
                            Text("\(QuantityFormat.text(unit.displayQuantity)) \(unit.unitType.displayName)")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .frame(minHeight: 30)
                                .background(AppTheme.panelRaised)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(AppTheme.panelRaised.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func unitTotalsSummary(_ unitTotals: [(UnitType, Double)]) -> String {
        guard !unitTotals.isEmpty else { return "No counted stock" }

        return unitTotals
            .map { "\(QuantityFormat.text($0.1)) \($0.0.displayName)" }
            .joined(separator: ", ")
    }

    private func expansionKey(category: AlcoholCategory, tier: InventoryTier) -> String {
        "\(category.rawValue)-\(tier.rawValue)"
    }

    private func statusSection(title: String, items: [InventoryItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: title)
            if items.isEmpty {
                EmptyStateView(title: "All clear", message: "Nothing needs attention here.")
            } else {
                ForEach(items) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name).font(.headline)
                            Text("\(item.category.displayName) • \(item.tier.displayName)")
                                .font(.caption)
                                .foregroundStyle(AppTheme.muted)
                            if title == "Low Stock" {
                                Text("\(QuantityFormat.text(item.totalQuantity)) on hand • threshold \(item.lowStockThreshold)")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.accent)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(AppTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }
}
