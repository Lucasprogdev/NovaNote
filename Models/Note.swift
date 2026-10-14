import Foundation
import SwiftData

@Model
final class Note {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var isPinned: Bool
    var isFavorite: Bool
    var isArchived: Bool
    var createdAt: Date
    var modifiedAt: Date
    
    @Relationship(inverse: \Folder.notes) var folder: Folder?
    @Relationship(inverse: \Tag.notes) var tags: [Tag]?
    
    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        isPinned: Bool = false,
        isFavorite: Bool = false,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        folder: Folder? = nil,
        tags: [Tag]? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.isPinned = isPinned
        self.isFavorite = isFavorite
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.folder = folder
        self.tags = tags
    }
}
