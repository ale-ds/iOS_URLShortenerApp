import UIKit

extension UIImage {
    convenience init?(localized identifier: ImageIdentifier, configuration: UIImage.Configuration? = nil) {
        let imageName = identifier.name
        
        if identifier.isSystem {
            self.init(systemName: imageName, withConfiguration: configuration)
        } else {
            self.init(named: imageName)
        }
    }
}
