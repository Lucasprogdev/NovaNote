import SwiftUI

struct Constants {
    struct Colors {
        static let background = Color.black
        static let cardBackground = Color(red: 0.08, green: 0.08, blue: 0.08)
        static let surfaceBackground = Color(red: 0.12, green: 0.12, blue: 0.14)
        static let textPrimary = Color.white
        static let textSecondary = Color.gray
        static let border = Color(red: 0.2, green: 0.2, blue: 0.22)
        static let accent = Color.blue
    }
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 28
    }
    
    struct Radius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let lg: CGFloat = 18
        static let xl: CGFloat = 24
    }
}
