import SwiftUI

struct NoteRowView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Text(note.title.isEmpty ? "Sans titre" : note.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Constants.Colors.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.yellow.opacity(0.9))
                }
                
                if note.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.orange.opacity(0.9))
                }
            }
            
            Text(previewText)
                .font(.system(size: 13))
                .foregroundStyle(Constants.Colors.textSecondary)
                .lineLimit(2)
            
            HStack {
                if let folder = note.folder {
                    Text(folder.name)
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, Constants.Spacing.sm)
                        .padding(.vertical, Constants.Spacing.xs)
                        .background(Color(hex: folder.colorHex).opacity(0.3))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: folder.colorHex), lineWidth: 0.5)
                        )
                }
                
                Spacer()
                
                Text(formattedDate)
                    .font(.system(size: 11))
                    .foregroundStyle(Constants.Colors.textSecondary.opacity(0.7))
            }
        }
        .padding(Constants.Spacing.lg)
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Radius.lg)
                .stroke(Constants.Colors.border, lineWidth: 0.5)
        )
    }
    
    private var previewText: String {
        let trimmed = note.content.replacingOccurrences(
            of: "\n",
            with: " "
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Aucun contenu" : trimmed
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(note.modifiedAt) {
            formatter.timeStyle = .short
        } else {
            formatter.dateStyle = .short
        }
        return formatter.string(from: note.modifiedAt)
    }
}
