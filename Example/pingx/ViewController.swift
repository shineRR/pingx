import UIKit

// MARK: - ViewController

final class ViewController: UIViewController {
    
    // MARK: UI Components
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: Properties
    
    private let presenter: Presenter
    
    // MARK: Initializer
    
    init(presenter: Presenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Override

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// MARK: - PingxView

extension ViewController: PingxView {}

// MARK: - Actions Extension

private extension ViewController {
    @objc
    func didTapButton() {
        presenter.didTapSendButton()
    }
}

// MARK: - UI Extension

private extension ViewController {
    func setUp() {
        setUpHierarchy()
        setUpConstraints()
    }
    
    func setUpHierarchy() {
        view.backgroundColor = .white
        view.addSubview(sendButton)
    }
    
    func setUpConstraints() {
        NSLayoutConstraint.activate([
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
