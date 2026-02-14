import UIKit
@testable import URLShortener

private extension URLInputView {
    var errorContainerViewIsHidden: Bool {
        subviewsRecursive(of: UIView.self).first { $0 != self && $0.isHidden }?.isHidden ?? true
    }

    var retryButtonIsHidden: Bool {
        subviewsRecursive(of: UIButton.self).first { $0.title(for: .normal) != nil }?.isHidden ?? true
    }

    var errorLabelText: String? {
        subviewsRecursive(of: UILabel.self).first?.text
    }

    var inputBorderWidth: CGFloat {
        subviewsRecursive(of: UIView.self).first?.layer.borderWidth ?? 0
    }

    var isLoading: Bool {
        subviewsRecursive(of: UIActivityIndicatorView.self).first?.isAnimating ?? false
    }
}

private extension UIView {
    func subviewsRecursive<T: UIView>(of type: T.Type) -> [T] {
        subviews.compactMap { $0 as? T } +
        subviews.flatMap { $0.subviewsRecursive(of: type) }
    }
}
