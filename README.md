# Mimby

Mimby is an iPhone-first SwiftUI + SwiftData MVP for managing wedding venue alcohol inventory as a manual on-hand snapshot.

## Project Structure

- `Mimby.xcodeproj` - Xcode project
- `Mimby/MimbyApp.swift` - app entry point and SwiftData container
- `Mimby/Models` - SwiftData models and core enums
- `Mimby/Services` - shopping list calculator and starter sample data
- `Mimby/ViewModels` - dashboard and event builder view models
- `Mimby/Views` - tab views, inventory editing, event builder, shopping list, settings, and recount flow

## MVP Boundaries

This version does not include POS tracking, automatic event depletion, barcode scanning, supplier ordering, multi-user permissions, CloudKit sync, or analytics beyond simple grouped totals.

