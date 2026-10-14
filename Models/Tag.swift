import Foundation
import SwiftData

@Model
final class Tag {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var createdAt: Date
    var notes: [Note]?
    
    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#6C5CE7",
        createdAt: Date = Date(),
        notes: [Note]? = nil
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.notes = notes
    }
}
