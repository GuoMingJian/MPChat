import UIKit

public class DatePickViewController: UIViewController {
    public var onDateSelected: ((Date) -> Void)?
    public var onCancel: (() -> Void)?
    
    public let datePicker = UIDatePicker()
    
    public var selectedDate: Date = Date()
    public var minimumDate: Date?
    public var maximumDate: Date?
    
    // 文本配置
    public var cancelButtonTitle: String = "cancel".mj_Localized()
    public var confirmButtonTitle: String = "confirm".mj_Localized()
    public var titleText: String = "select_date".mj_Localized()
    
    private let backgroundView = UIView()
    private let containerView = UIView()
    private let headerView = UIView()
    private let cancelButton = UIButton(type: .system)
    private let confirmButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupDatePicker()
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showWithAnimation()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.clear
        
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView.addGestureRecognizer(tapGesture)
        
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.clipsToBounds = true
        
        headerView.backgroundColor = UIColor.systemBackground
        
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        confirmButton.setTitle(confirmButtonTitle, for: .normal)
        confirmButton.setTitleColor(.black, for: .normal)
        confirmButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        titleLabel.text = titleText
        titleLabel.textColor = .label
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
            // iOS 13.4 以下使用旧样式
        }
        datePicker.locale = Locale(identifier: "en_US")
    }
    
    private func setupConstraints() {
        // 添加视图到层级
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        containerView.addSubview(headerView)
        containerView.addSubview(datePicker)
        headerView.addSubview(cancelButton)
        headerView.addSubview(titleLabel)
        headerView.addSubview(confirmButton)
        
        // 设置 translatesAutoresizingMaskIntoConstraints
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // 背景视图约束
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 容器视图约束
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 320)
        ])
        
        // 头部视图约束
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // 取消按钮约束
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            cancelButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        // 标题标签约束
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        // 确认按钮约束
        NSLayoutConstraint.activate([
            confirmButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            confirmButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        // 日期选择器约束
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            datePicker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func setupDatePicker() {
        // 只有当没有设置最小/最大日期时才设置默认值
        if minimumDate == nil && maximumDate == nil {
            let calendar = Calendar.current
            let currentDate = Date()
            
            let minDate = calendar.date(byAdding: .year, value: -65, to: currentDate)!
            let maxDate = calendar.date(byAdding: .year, value: -18, to: currentDate)!
            
            self.minimumDate = minDate
            self.maximumDate = maxDate
        }
        
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        datePicker.date = selectedDate
    }
    
    private func showWithAnimation() {
        view.layoutIfNeeded()
        containerView.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.backgroundView.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    private func hideWithAnimation(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.backgroundView.alpha = 0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.frame.height)
        } completion: { _ in
            completion()
        }
    }
    
    @objc private func backgroundTapped() {
        dismissWithCancel()
    }
    
    @objc private func cancelButtonTapped() {
        dismissWithCancel()
    }
    
    @objc private func confirmButtonTapped() {
        let selectedDate = datePicker.date
        onDateSelected?(selectedDate)
        
        hideWithAnimation {
            self.dismiss(animated: false)
        }
    }
    
    private func dismissWithCancel() {
        onCancel?()
        
        hideWithAnimation {
            self.dismiss(animated: false)
        }
    }
    
    public func configure(selectedDate: Date? = nil,
                          minimumDate: Date? = nil,
                          maximumDate: Date? = nil,
                          cancelTitle: String? = nil,
                          confirmTitle: String? = nil,
                          title: String? = nil) {
        
        if let selectedDate = selectedDate {
            self.selectedDate = selectedDate
        }
        
        if let minimumDate = minimumDate {
            self.minimumDate = minimumDate
        }
        
        if let maximumDate = maximumDate {
            self.maximumDate = maximumDate
        }
        
        if let cancelTitle = cancelTitle {
            self.cancelButtonTitle = cancelTitle
            cancelButton.setTitle(cancelTitle, for: .normal)
        }
        
        if let confirmTitle = confirmTitle {
            self.confirmButtonTitle = confirmTitle
            confirmButton.setTitle(confirmTitle, for: .normal)
        }
        
        if let title = title {
            self.titleText = title
            titleLabel.text = title
        }
        
        // 如果视图已经加载，立即更新 datePicker
        if isViewLoaded {
            datePicker.minimumDate = self.minimumDate
            datePicker.maximumDate = self.maximumDate
            datePicker.date = self.selectedDate
        }
    }
}

public extension DatePickViewController {
    @discardableResult
    static func show(on vc: UIViewController,
                            selectedDate: Date? = nil,
                            minimumDate: Date? = nil,
                            maximumDate: Date? = nil,
                            cancelTitle: String = "cancel".mj_Localized(),
                            confirmTitle: String = "confirm".mj_Localized(),
                            title: String = "select_date".mj_Localized(),
                            onDateSelected: @escaping (Date) -> Void,
                            onCancel: (() -> Void)? = nil) -> DatePickViewController {
        
        let datePickerVC = DatePickViewController()
        datePickerVC.modalPresentationStyle = .custom
        datePickerVC.modalTransitionStyle = .crossDissolve
        
        datePickerVC.onDateSelected = onDateSelected
        datePickerVC.onCancel = onCancel
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        let defaultMinDate = minimumDate ?? calendar.date(byAdding: .year, value: -65, to: currentDate)!
        let defaultMaxDate = maximumDate ?? calendar.date(byAdding: .year, value: -18, to: currentDate)!
        let defaultSelectedDate = selectedDate ?? defaultMaxDate
        
        datePickerVC.configure(selectedDate: defaultSelectedDate,
                               minimumDate: defaultMinDate,
                               maximumDate: defaultMaxDate,
                               cancelTitle: cancelTitle,
                               confirmTitle: confirmTitle,
                               title: title)
        
        vc.present(datePickerVC, animated: false)
        
        return datePickerVC
    }
}
