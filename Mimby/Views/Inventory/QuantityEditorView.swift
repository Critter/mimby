import SwiftUI

struct QuantityEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var unit: InventoryUnit
    @State private var draftQuantity: Int

    init(unit: InventoryUnit) {
        self.unit = unit
        _draftQuantity = State(initialValue: unit.quantity)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Text(unit.unitType.displayName)
                    .font(.title2.bold())

                HStack(spacing: 16) {
                    Button { draftQuantity = max(draftQuantity - 1, 0) } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 46))
                    }
                    .accessibilityLabel("Decrease")

                    TextField("Quantity", value: $draftQuantity, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 44, weight: .bold))
                        .frame(width: 120)

                    Button { draftQuantity += 1 } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 46))
                    }
                    .accessibilityLabel("Increase")
                }
                .tint(AppTheme.accent)

                HStack {
                    Button("Cancel") { dismiss() }.buttonStyle(SecondaryButtonStyle())
                    Button("Save") {
                        unit.quantity = max(draftQuantity, 0)
                        unit.item?.updatedAt = .now
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding()
            .background(AppTheme.background.ignoresSafeArea())
        }
    }
}

