
import UIKit
import Combine

open class BasePopController: UIViewController {
    public var cancellables = Set<AnyCancellable>()
    
    public var isBackgroundTapEnabled: Bool = true
    public var onBackgroundTap: (() -> Void)?
    
    public lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()
    
    public lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    public lazy var dragIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        view.layer.cornerRadius = 2
        return view
    }()
    
    public lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var initialContainerFrame: CGRect = .zero
    private var isDismissing = false
    
    open var containerHeight: CGFloat { 400 }
    open var dismissThreshold: CGFloat { 100 }
    open var animationDuration: TimeInterval { 0.35 }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        setupConstraints()
        setupContent()
        DispatchQueue.main.async {
            self.presentWithAnimation()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        containerView.addSubview(dragIndicator)
        containerView.addSubview(contentView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    private func setupGestures() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        containerView.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func setupConstraints() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        dragIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: containerHeight),
            
            dragIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            dragIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dragIndicator.widthAnchor.constraint(equalToConstant: 36),
            dragIndicator.heightAnchor.constraint(equalToConstant: 4),
            
            contentView.topAnchor.constraint(equalTo: dragIndicator.bottomAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func presentWithAnimation() {
        containerView.transform = CGAffineTransform(translationX: 0, y: containerHeight)
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: { [weak self] in
                self?.backgroundView.alpha = 1
                self?.containerView.transform = .identity
            },
            completion: nil
        )
    }
    
    public func dismissWithAnimation(completion: (() -> Void)? = nil) {
        guard !isDismissing else { return }
        isDismissing = true
        
        guard isBackgroundTapEnabled else {
            onBackgroundTap?()
            return
        }
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseOut],
            animations: { [weak self] in
                guard let self = self else { return }
                self.backgroundView.alpha = 0
                self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerHeight)
            },
            completion: { _ in
                self.dismiss(animated: false) {
                    completion?()
                }
            }
        )
    }
    
    @objc private func backgroundTapped() {
        dismissWithAnimation()
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .began:
            initialContainerFrame = containerView.frame
            
        case .changed:
            let newTranslationY = max(0, translation.y)
            containerView.transform = CGAffineTransform(translationX: 0, y: newTranslationY)
            
            let progress = newTranslationY / containerHeight
            backgroundView.alpha = 1 - (progress * 0.5)
            
        case .ended, .cancelled:
            let shouldDismiss = translation.y > dismissThreshold || velocity.y > 500
            
            if shouldDismiss {
                dismissWithAnimation()
            } else {
                UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut]) {
                    self.containerView.transform = .identity
                    self.backgroundView.alpha = 1
                }
            }
            
        default:
            break
        }
    }
    
    open func setupContent() {
        
    }
}

extension UIViewController {
    
    public func present(to popController: UIViewController) {
        popController.modalPresentationStyle = .custom
        popController.modalTransitionStyle = .crossDissolve
        self.present(popController, animated: false)
    }
    
    public static func present(from viewController: UIViewController, to popController: UIViewController) {
        popController.modalPresentationStyle = .custom
        popController.modalTransitionStyle = .crossDissolve
        viewController.present(popController, animated: false)
    }
}
