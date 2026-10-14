import SwiftUI

struct FolderCardView: View {
    let folder: Folder
    let noteCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
            HStack {
                Circle()
                    .fill(Color(hex: folder.colorHex))
                    .frame(width: 10, height: 10)
                Spacer()
                Text("\(noteCount)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Constants.Colors.textSecondary)
                    .padding(.horizontal, Constants.Spacing.sm)
                    .padding(.vertical, Constants.Spacing.xs)
                    .background(Constants.Colors.surfaceBackground)
                    .clipShape(Capsule())
            }
            
            Text(folder.name)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Constants.Colors.textPrimary)
                .lineLimit(2)
        }
        .padding(Constants.Spacing.lg)
        .background(Constants.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Radius.lg)
                .stroke(Constants.Colors.border, lineWidth: 0.5)
        )
    }
}
