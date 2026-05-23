import SwiftUI
import SwiftData
import UIKit

struct ShoppingListView: View {
    @Query(sort: \ShoppingListItem.createdAt, order: .reverse) private var shoppingItems: [ShoppingListItem]
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.itemName).font(.headline)
                        HStack {
                            shoppingMetric("Need", item.quantityNeeded, item.unitType)
                            shoppingMetric("On Hand", item.quantityOnHand, item.unitType)
                            shoppingMetric("Buy", item.quantityToBuy, item.unitType, highlight: true)
                        }
                    }
                    .padding()
                    .background(AppTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
