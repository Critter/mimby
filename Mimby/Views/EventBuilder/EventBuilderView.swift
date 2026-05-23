import SwiftUI
import SwiftData

struct EventBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InventoryItem.name) private var inventory: [InventoryItem]
    @Query private var requirements: [EventRequirement]
    @State private var viewModel = EventBuilderViewModel()

    private var matchingItems: [InventoryItem] {
        inventory.filter {
            !$0.isArchived &&
            $0.category == viewModel.selectedCategory &&
            $0.tier == viewModel.selectedTier
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    builder
                    requirementsList
                    calculateButton
                }
                .padding()
            }
            .navigationTitle("Event Builder")
            .mimbyScreen()
        }
    }

    private var builder: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Need")

            Picker("Category", selection: $viewModel.selectedCategory) {
                ForEach(AlcoholCategory.allCases) { Text($0.displayName).tag($0) }
            }
            .pickerStyle(.segmented)

            Picker("Tier", selection: $viewModel.selectedTier) {
                ForEach(viewModel.selectedCategory.tiers) { Text($0.displayName).tag($0) }
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.selectedTier) { viewModel.specificItemID = nil }

            Picker("Unit", selection: $viewModel.selectedUnit) {
                ForEach(viewModel.selectedCategory.allowedUnits) { Text($0.displayName).tag($0) }
            }
            .pickerStyle(.segmented)

            Stepper(value: $viewModel.quantityNeeded, in: 0...999) {
                Text("\(viewModel.quantityNeeded) \(viewModel.selectedUnit.displayName)\(viewModel.quantityNeeded == 1 ? "" : "s")")
                    .font(.title3.bold())
            }

            Toggle("Specific item", isOn: $viewModel.useSpecificItem)
                .tint(AppTheme.accent)

            if viewModel.useSpecificItem {
                Picker("Item", selection: $viewModel.specificItemID) {
                    Text("Choose item").tag(Optional<UUID>.none)
                    ForEach(matchingItems) { item in
                        Text(item.name).tag(Optional(item.id))
                    }
                }
                .pickerStyle(.menu)
            }

            Button("Add Requirement") {
                viewModel.addRequirement(context: modelContext, inventory: inventory)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(viewModel.useSpecificItem && viewModel.specificItemID == nil)
        }
        .padding()
        .background(AppTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var requirementsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Event List")
            if requirements.isEmpty {
                EmptyStateView(title: "No requirements yet", message: "Add what the bar should have ready for this event.")
            } else {
                ForEach(requirements) { requirement in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(requirement.specificItem?.name ?? "\(requirement.tier.displayName) \(requirement.category.displayName)")
                                .font(.headline)
                            Text("\(requirement.quantityNeeded) \(requirement.unitType.displayName) • \(requirement.category.displayName)")
                                .font(.caption)
                                .foregroundStyle(AppTheme.muted)
                        }
                        Spacer()
                        Button(role: .destructive) {
                            modelContext.delete(requirement)
                        } label: {
                            Image(systemName: "trash")
                                .frame(width: 44, height: 44)
                        }
                    }
                    .padding()
                    .background(AppTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }

    private var calculateButton: some View {
        Button("Calculate Shopping List") {
            let oldItems = try? modelContext.fetch(FetchDescriptor<ShoppingListItem>())
            oldItems?.forEach { modelContext.delete($0) }

            let results = ShoppingListCalculator.calculate(requirements: requirements, inventory: inventory)
            results.forEach { modelContext.insert($0) }
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}
