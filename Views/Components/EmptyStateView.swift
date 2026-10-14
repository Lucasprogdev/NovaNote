import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: Constants.Spacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 60, weight: .thin))
                .foregroundStyle(.white.opacity(0.3))
            
            VStack(spacing: Constants.Spacing.sm) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Constants.Colors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(Constants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.Spacing.xl)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.Spacing.xxl)
    }
}
