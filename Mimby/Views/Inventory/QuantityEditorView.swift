import SwiftUI

struct QuantityEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var unit: InventoryUnit
    @State private var draftQuantity: Double

    init(unit: InventoryUnit) {
        self.unit = unit
        _draftQuantity = State(initialValue: unit.displayQuantity)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Text(unit.unitType.displayName)
                    .font(.title2.bold())

                HStack(spacing: 16) {
                    Button { adjustDraftQuantity(by: -0.25) } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 46))
                    }
                    .accessibilityLabel("Decrease")

                    TextField("Quantity", value: $draftQuantity, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 44, weight: .bold))
                        .frame(width: 120)

                    Button { adjustDraftQuantity(by: 0.25) } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 46))
                    }
                    .accessibilityLabel("Increase")
                }
                .tint(AppTheme.accent)

                HStack {
                    Button("Cancel") { dismiss() }.buttonStyle(SecondaryButtonStyle())
                    Button("Save") {
                        unit.displayQuantity = max(draftQuantity, 0)
                        unit.item?.updatedAt = .now
                        try? unit.modelContext?.save()
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding()
            .background(AppTheme.background.ignoresSafeArea())
        }
    }

    private func adjustDraftQuantity(by amount: Double) {
        draftQuantity = (max(draftQuantity + amount, 0) * 4.0).rounded() / 4.0
    }
}
