import UIKit

enum ImageIdentifier: String {
    case iconCopy
    case iconCheckmark
    case iconArrowRight
    case iconRetry
    case logoApp
    
    var name: String {
        return NSLocalizedString(self.rawValue, bundle: .main, comment: "")
    }
    
    var isSystem: Bool {
        return self.rawValue.contains("icon")
    }
}
