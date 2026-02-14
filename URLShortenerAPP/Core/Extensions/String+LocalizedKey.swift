import Foundation

extension String {
    
    public init(localized key: LocalizedKey) {
        self.init(NSLocalizedString(key.rawValue, comment: ""))
    }
    
    public init(localized key: LocalizedKey, comment: String) {
        self.init(NSLocalizedString(key.rawValue, comment: comment))
    }
}
