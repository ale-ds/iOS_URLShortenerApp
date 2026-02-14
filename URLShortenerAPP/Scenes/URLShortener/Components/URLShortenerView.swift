import UIKit

final class URLShortenerView: UIView {
    
    // MARK: - Event Closures
    var onShortenRequested: ((String) -> Void)?
    var onRetryRequested: ((String) -> Void)?
    var onCopyRequested: ((String) -> Void)?
    var onTyping: (() -> Void)?
    
    // MARK: - Private State
    private var historyItems: [URLShortenerModels.Shorten.HistoryItem] = []
    
    // MARK: - UI Components
    private lazy var urlInputView: URLInputView = {
        let view = URLInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.onShorten = { [weak self] text in
            self?.onShortenRequested?(text)
        }
        
        view.onRetry = { [weak self] text in
            self?.onRetryRequested?(text)
        }
        
        view.onTyping = { [weak self] in
            self?.onTyping?()
        }
        
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemBackground
        tv.separatorStyle = .none
        
        // Registros
        tv.register(URLHistoryCell.self, forCellReuseIdentifier: URLHistoryCell.identifier)
        tv.register(URLSectionHeader.self, forHeaderFooterViewReuseIdentifier: URLSectionHeader.identifier)
        
        tv.showsVerticalScrollIndicator = false
        tv.keyboardDismissMode = .onDrag
        
        // View é o DataSource
        tv.dataSource = self
        tv.delegate = self
        
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0
        }
        
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var emptyStateView: UILabel = {
        let label = UILabel()
        // Se der erro aqui, substitua por "No history yet"
        label.text = String(localized: .uiEmptyStateMessage)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public API
    func update(state: ViewState<URLShortenerModels.Shorten.ViewModel>) {
        switch state {
        case .idle:
            urlInputView.stopLoading()
            urlInputView.hideError()
            
        case .loading:
            urlInputView.startLoading()
            urlInputView.hideError()
            
        case .success(let viewModel):
            urlInputView.stopLoading()
            urlInputView.clearInput()
            
            historyItems = viewModel.history
            tableView.reloadData()
            toggleEmptyState(isEmpty: viewModel.history.isEmpty)
            
        case .error(let errorViewModel):
            urlInputView.stopLoading()
            urlInputView.showError(error: errorViewModel)
        
        case .empty:
            urlInputView.stopLoading()
            historyItems = []
            tableView.reloadData()
            toggleEmptyState(isEmpty: true)
        }
    }
    
    private func toggleEmptyState(isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}
// MARK: - ViewConfiguration
extension URLShortenerView: ViewConfiguration {
    
    func buildHierarchy() {
        addSubview(urlInputView)
        addSubview(tableView)
        addSubview(emptyStateView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            urlInputView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            urlInputView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            urlInputView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: urlInputView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
    
    func configureViews() {
        backgroundColor = .systemBackground
    }
}

// MARK: - UITableViewDataSource
extension URLShortenerView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: URLHistoryCell.identifier,
            for: indexPath) as? URLHistoryCell else {
            
            return UITableViewCell()
        }
        
        let item = historyItems[indexPath.row]
        cell.configure(original: item.original, short: item.short)
        
        cell.onCopy = { [weak self] shortURL in
            self?.onCopyRequested?(shortURL)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension URLShortenerView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !historyItems.isEmpty else { return nil }
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: URLSectionHeader.identifier)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return historyItems.isEmpty ? 0 : 40
    }
}
