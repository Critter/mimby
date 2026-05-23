import Foundation

enum AlcoholCategory: String, CaseIterable, Identifiable, Codable, Hashable {
    case beer
    case wine
    case liquor

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beer: "Beer"
        case .wine: "Wine"
        case .liquor: "Liquor"
        }
    }

    var tiers: [InventoryTier] {
        switch self {
        case .beer: [.domestic, .importTier, .craft]
        case .wine, .liquor: [.house, .mid, .premium]
        }
    }

    var allowedUnits: [UnitType] {
        switch self {
        case .beer: [.caseUnit, .twelvePack, .sixPack, .single]
        case .wine, .liquor: [.bottle]
        }
    }
}

enum InventoryTier: String, CaseIterable, Identifiable, Codable, Hashable {
    case domestic
    case importTier
    case craft
    case house
    case mid
    case premium

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .domestic: "Domestic"
        case .importTier: "Import"
        case .craft: "Craft"
        case .house: "House"
        case .mid: "Mid"
        case .premium: "Premium"
        }
    }
}

enum UnitType: String, CaseIterable, Identifiable, Codable, Hashable {
    case caseUnit
    case twelvePack
    case sixPack
    case single
    case bottle

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .caseUnit: "Case"
        case .twelvePack: "12 Pack"
        case .sixPack: "6 Pack"
        case .single: "Single"
        case .bottle: "Bottle"
        }
    }
}
