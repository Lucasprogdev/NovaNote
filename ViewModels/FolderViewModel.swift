import Foundation
import SwiftData
import SwiftUI

@MainActor
final class FolderViewModel: ObservableObject {
    @Published var isCreatingFolder: Bool = false
    @Published var newFolderName: String = ""
    @Published var newFolderColor: String = "#4A90E2"
}
