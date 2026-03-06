//
//  LimitTextView.swift
//  MJKit
//
//  Created by 郭明健 on 2025/10/17.
//

/*
 private lazy var limitTextView: LimitTextView = {
     let textView = LimitTextView()
     var config = LimitTextView.Configuration()
     config.placeholder = "Please enter..."
     config.placeholderColor = .lightGray
     config.maxInputCount = 200
     config.bgColor = .systemGray6
     config.cornerRadius = 10
     
     textView.setup(config: config)
     return textView
 }()
 */

import UIKit

public class LimitTextView: UIView {
    
    // MARK: - UI Components
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.textAlignment = .right
        return label
    }()
    
    public lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        return textView
    }()
    
    // MARK: - Configuration
    public struct Configuration {
        /// placeholder
        public var placeholder: String = ""
        public var placeholderColor: UIColor = .lightGray
        public var placeholderFont: UIFont = UIFont.systemFont(ofSize: 16)
        public var placeholderTopConstraint: CGFloat = 8
        public var placeholderLeadingConstraint: CGFloat = 8
        /// count
        public var countColor: UIColor = .lightGray
        public var countFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        public var countTrailingConstraint: CGFloat = 10
        public var countBottomConstraint: CGFloat = 10
        public var isShowCountLabel: Bool = true
        /// textView
        public var text: String = ""
        public var textColor: UIColor = .black
        public var textFont: UIFont = UIFont.systemFont(ofSize: 16)
        //
        public var bgColor: UIColor = .systemGray6
        public var cornerRadius: CGFloat = 10
        public var maxInputCount: Int = 200
        
        public init(
            placeholder: String = "",
            placeholderColor: UIColor = .lightGray,
            placeholderFont: UIFont = UIFont.systemFont(ofSize: 16),
            placeholderTopConstraint: CGFloat = 8,
            placeholderLeadingConstraint: CGFloat = 8,
            countColor: UIColor = .lightGray,
            countFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .semibold),
            countTrailingConstraint: CGFloat = 10,
            countBottomConstraint: CGFloat = 10,
            isShowCountLabel: Bool = true,
            text: String = "",
            textColor: UIColor = .black,
            textFont: UIFont = UIFont.systemFont(ofSize: 16),
            bgColor: UIColor = .systemGray6,
            cornerRadius: CGFloat = 10,
            maxInputCount: Int = 200
        ) {
            self.placeholder = placeholder
            self.placeholderColor = placeholderColor
            self.placeholderFont = placeholderFont
            self.placeholderTopConstraint = placeholderTopConstraint
            self.placeholderLeadingConstraint = placeholderLeadingConstraint
            self.countColor = countColor
            self.countFont = countFont
            self.countTrailingConstraint = countTrailingConstraint
            self.countBottomConstraint = countBottomConstraint
            self.isShowCountLabel = isShowCountLabel
            self.text = text
            self.textColor = textColor
            self.textFont = textFont
            self.bgColor = bgColor
            self.cornerRadius = cornerRadius
            self.maxInputCount = maxInputCount
        }
        
        public init() {}
    }
    
    // MARK: - Properties
    private var config: Configuration = Configuration()
    private var maxInputCount: Int = 200
    public var currentInputText: String = "" {
        didSet {
            placeholderLabel.isHidden = !currentInputText.isEmpty
            countLabel.text = "\(currentInputText.count)/\(maxInputCount)"
        }
    }
    public var textDidChangedCallback: ((_ text: String) -> Void)?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Public Methods
    public func setup(config: Configuration) {
        self.config = config
        setupUI()
    }
    
    public func getCurrentText() -> String {
        return currentInputText
    }
    
    public func setText(_ text: String) {
        if text.count > config.maxInputCount {
            currentInputText = String(text.prefix(config.maxInputCount))
        } else {
            currentInputText = text
        }
        textView.text = currentInputText
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        // 清除旧约束
        subviews.forEach { $0.removeFromSuperview() }
        
        // 添加子视图
        addSubview(contentView)
        contentView.addSubview(placeholderLabel)
        contentView.addSubview(textView)
        contentView.addSubview(countLabel)
        
        // 设置约束
        setupConstraints()
        
        // 配置样式
        configureStyle()
    }
    
    private func setupConstraints() {
        // contentView 约束
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // placeholderLabel 约束
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: config.placeholderTopConstraint),
            placeholderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: config.placeholderLeadingConstraint),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -config.placeholderLeadingConstraint)
        ])
        
        // textView 约束
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // countLabel 约束
        NSLayoutConstraint.activate([
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -config.countTrailingConstraint),
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -config.countBottomConstraint)
        ])
        
        // 设置 textView 的内边距
        let vOffset = config.placeholderTopConstraint
        let hOffset = config.placeholderLeadingConstraint - 3
        textView.textContainerInset = UIEdgeInsets(top: vOffset, left: hOffset, bottom: vOffset, right: hOffset)
    }
    
    private func configureStyle() {
        // 配置 contentView
        contentView.backgroundColor = config.bgColor
        contentView.layer.cornerRadius = config.cornerRadius
        contentView.clipsToBounds = true
        
        // 配置 placeholder
        placeholderLabel.text = config.placeholder
        placeholderLabel.textColor = config.placeholderColor
        placeholderLabel.font = config.placeholderFont
        
        // 配置 countLabel
        countLabel.textColor = config.countColor
        countLabel.font = config.countFont
        countLabel.isHidden = !config.isShowCountLabel
        
        // 配置 textView
        textView.text = config.text
        textView.textColor = config.textColor
        textView.font = config.textFont
        
        // 初始化文本状态
        if !config.text.isEmpty {
            if config.text.count > config.maxInputCount {
                currentInputText = String(config.text.prefix(config.maxInputCount))
            } else {
                currentInputText = config.text
            }
            textView.text = currentInputText
        } else {
            currentInputText = ""
        }
        
        maxInputCount = config.maxInputCount
        countLabel.text = "\(currentInputText.count)/\(maxInputCount)"
        placeholderLabel.isHidden = !currentInputText.isEmpty
    }
}

// MARK: - UITextViewDelegate
extension LimitTextView: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeholderLabel.isHidden = false
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        currentInputText = textView.text
        textDidChangedCallback?(currentInputText)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 允许删除字符
        if text.isEmpty {
            return true
        }
        
        // 检查是否超过最大输入限制
        let currentText = textView.text ?? ""
        let newLength = currentText.count + text.count - range.length
        return newLength <= maxInputCount
    }
}
