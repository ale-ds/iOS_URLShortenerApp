import Foundation

public protocol CustomIdentifier {
    var key: String { get }
}

extension CustomIdentifier where Self: RawRepresentable, Self.RawValue == String {
    
    public var key: String { return self.rawValue }
    
}
