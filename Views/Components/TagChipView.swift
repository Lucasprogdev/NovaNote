import SwiftUI

struct TagChipView: View {
    let tag: Tag
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Constants.Spacing.xs) {
                Circle()
                    .fill(Color(hex: tag.colorHex))
                    .frame(width: 6, height: 6)
                Text(tag.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isSelected ? .black : Constants.Colors.textPrimary)
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.vertical, Constants.Spacing.sm)
            .background(
                isSelected
                    ? Color(hex: tag.colorHex)
                    : Color(hex: tag.colorHex).opacity(0.2)
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color(hex: tag.colorHex), lineWidth: isSelected ? 0 : 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
