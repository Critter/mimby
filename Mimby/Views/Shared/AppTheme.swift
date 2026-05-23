import SwiftUI

enum AppTheme {
    static let background = Color(red: 0.05, green: 0.055, blue: 0.065)
    static let panel = Color(red: 0.10, green: 0.105, blue: 0.12)
    static let panelRaised = Color(red: 0.14, green: 0.145, blue: 0.16)
    static let accent = Color(red: 0.89, green: 0.72, blue: 0.38)
    static let danger = Color(red: 0.95, green: 0.34, blue: 0.31)
    static let muted = Color.white.opacity(0.64)
}

enum QuantityFormat {
    static func text(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }

        return String(format: "%.2f", value)
            .replacingOccurrences(of: "0$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\.$", with: "", options: .regularExpression)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(AppTheme.accent.opacity(configuration.isPressed ? 0.75 : 1))
            .foregroundStyle(.black)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(AppTheme.panelRaised.opacity(configuration.isPressed ? 0.7 : 1))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 10)
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title).font(.headline).foregroundStyle(.white)
            Text(message).font(.subheadline).foregroundStyle(AppTheme.muted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(AppTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

extension View {
    func mimbyScreen() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(AppTheme.background.ignoresSafeArea())
            .preferredColorScheme(.dark)
    }
}
