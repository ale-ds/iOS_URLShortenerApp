import UIKit

final class URLInputView: UIView {
    
    // MARK: - Event Closures
    var onShorten: ((String) -> Void)?
    var onRetry: ((String) -> Void)?
    var onTyping: (() -> Void)?
    
    // MARK: - UI Elements
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = String(localized: .uiInputPlaceholder)
        tf.borderStyle = .none
        tf.autocapitalizationType = .none
        tf.keyboardType = .URL
        tf.returnKeyType = .go
        tf.autocorrectionType = .no
        tf.delegate = self
        tf.inputAccessoryView = keyboardToolbar
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var actionButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        btn.setImage(UIImage(localized: .iconArrowRight, configuration: config), for: .normal)
        btn.tintColor = .systemBlue
        btn.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var errorContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.setContentHuggingPriority(.required, for: .vertical)
        return view
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .preferredFont(forTextStyle: .caption1)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(String(localized: .uiButtonRetry), for: .normal)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        btn.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.setContentCompressionResistancePriority(.required, for: .horizontal)
        btn.setContentHuggingPriority(.required, for: .horizontal)
        return btn
    }()
    
    private lazy var errorStackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var keyboardToolbar: UIToolbar = {
        let toolbar = UIToolbar(
            frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: 44
            )
        )
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let doneButton = UIBarButtonItem(
            title: String(localized: .uiButtonClose),
            style: .done,
            target: self,
            action: #selector(dismissKeyboard)
        )
        
        toolbar.setItems([flexSpace, doneButton], animated: false)
        return toolbar
    }()
    
    private var currentText: String? {
        guard let text = textField.text, !text.isEmpty else { return nil }
        textField.resignFirstResponder()
        return text
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func didTapAction() {
        guard let text = currentText else { return }
        onShorten?(text)
    }
    
    @objc private func didTapRetry() {
        guard let text = currentText else { return }
        onRetry?(text)
    }
    
    // MARK: - Private Methods
    @objc private func dismissKeyboard() {
        textField.resignFirstResponder()
    }
    
    // MARK: - Public State Methods (Renomeado para evitar conflito com CALayer)
    func update(state: ViewState<URLShortenerModels.Shorten.ViewModel>) {
        switch state {
        case .loading:
            startLoading()
        case .error(let viewModel):
            stopLoading()
            showError(error: viewModel)
        case .idle, .success, .empty:
            stopLoading()
            hideError()
            if case .success = state { clearInput() }
        }
    }
    
    func startLoading() {
        actionButton.isHidden = true
        loadingIndicator.startAnimating()
        textField.isEnabled = false
        hideError()
    }
    
    func stopLoading() {
        loadingIndicator.stopAnimating()
        actionButton.isHidden = false
        textField.isEnabled = true
    }
    
    func clearInput() {
        textField.text = ""
        hideError()
    }
    
    func showError(error: ErrorViewModel) {
        errorLabel.text = error.message
        retryButton.isHidden = !error.shouldRetry
        
        errorContainerView.isHidden = false
        inputContainerView.layer.borderWidth = 1
        inputContainerView.layer.borderColor = UIColor.systemRed.cgColor
        mainStackView.layoutIfNeeded()
    }
    
    func hideError() {
        errorContainerView.isHidden = true
        inputContainerView.layer.borderWidth = 0
        mainStackView.layoutIfNeeded()
    }
    
}

// MARK: - UITextFieldDelegate
extension URLInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapAction()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        onTyping?()
        return true
    }
}

// MARK: - ViewConfiguration
extension URLInputView: ViewConfiguration {
    
    func buildHierarchy() {
        addSubview(mainStackView)
        
        inputContainerView.addSubview(textField)
        inputContainerView.addSubview(actionButton)
        inputContainerView.addSubview(loadingIndicator)
        
        errorStackView.addArrangedSubview(errorLabel)
        errorStackView.addArrangedSubview(retryButton)
        errorContainerView.addSubview(errorStackView)
        
        mainStackView.addArrangedSubview(inputContainerView)
        mainStackView.addArrangedSubview(errorContainerView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            inputContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            textField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16),
            textField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -8),
            
            actionButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -8),
            actionButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 44),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: actionButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            
            // CORREÇÃO CRÍTICA 3: Constraints firmes para que o Stack empurre o Container
            errorStackView.topAnchor.constraint(equalTo: errorContainerView.topAnchor, constant: 4),
            errorStackView.leadingAnchor.constraint(equalTo: errorContainerView.leadingAnchor, constant: 4),
            errorStackView.trailingAnchor.constraint(equalTo: errorContainerView.trailingAnchor, constant: -4),
            errorStackView.bottomAnchor.constraint(equalTo: errorContainerView.bottomAnchor, constant: -4)
        ])
    }
    
    func configureViews() {
        backgroundColor = .clear
    }
}
