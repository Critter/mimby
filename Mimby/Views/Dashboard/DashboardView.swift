import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \InventoryItem.name) private var items: [InventoryItem]
    @State private var showAddInventory = false
    @State private var showRecount = false

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
                        HStack {
                            Text(tier.displayName)
                            Spacer()
                            Text("\(viewModel.total(category: category, tier: tier))")
                                .font(.title3.bold())
                                .foregroundStyle(AppTheme.accent)
                        }
                        .padding()
                        .background(AppTheme.panel)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }
        }
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

