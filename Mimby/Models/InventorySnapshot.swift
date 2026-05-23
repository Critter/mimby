import Foundation
import SwiftData

@Model
final class InventorySnapshot {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var notes: String
    var serializedInventorySummary: String

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = .now,
        notes: String = "",
        serializedInventorySummary: String
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.notes = notes
        self.serializedInventorySummary = serializedInventorySummary
    }
}

