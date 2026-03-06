//
//  BaseDialogView.swift
//  NeonMe
//
//  Created by 郭明健 on 2025/10/23.
//

import UIKit

/*
 var config = BaseDialogView.Configuration()
 config.titleStyle = BaseDialogView.LabelStyle(text: "Title")
 config.subTitleStyle = BaseDialogView.LabelStyle(text: "SubTitle")
 config.buttonOneStyle = BaseDialogView.LabelStyle.defaultButtonOneStyle()
 config.buttonTwoStyle = BaseDialogView.LabelStyle.defaultButtonTwoStyle()
 
 let type: DialogType = .verticalTwo
 if type == .verticalTwo {
     config.buttonOneStyle.text = "Comfirm"
     config.buttonOneStyle.textColor = UIColor.hexColor(color: "#03BDE3")
     config.buttonTwoStyle.text = "Cancel"
     config.buttonTwoStyle.textColor = UIColor.hexColor(color: "#333333")
 }
 
 BaseDialogView.showDialog(type: type, config: config) { btnIndex in
     if btnIndex != -1 {
         UIView.showTips("btnIndex: \(btnIndex)")
     }
 }
 */

// MARK: - 弹窗类型枚举
public enum DialogType: Int {
    case horizontalTwo = 0  // 水平方向两个按钮
    case verticalOne        // 垂直方向一个按钮
    case verticalTwo        // 垂直方向两个按钮
}

public class BaseDialogView: UIView {
    public struct LabelStyle {
        public var text: String
        public var textColor: UIColor
        public var font: UIFont
        
        public init(text: String = "",
                    textColor: UIColor = .black,
                    font: UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)) {
            self.text = text
            self.textColor = textColor
            self.font = font
        }
        
        public static func defaultButtonOneStyle() -> LabelStyle {
            return LabelStyle(text: "cancel".mj_Localized(), textColor: UIColor.hexColor(color: "#333333"), font: UIFont.systemFont(ofSize: 16, weight: .regular))
        }
        
        public static func defaultButtonTwoStyle() -> LabelStyle {
            return LabelStyle(text: "confirm".mj_Localized(), textColor: UIColor.hexColor(color: "#03BDE3"), font: UIFont.systemFont(ofSize: 16, weight: .regular))
        }
    }
    
    // MARK: - DialogConfiguration
    public struct Configuration {
        public var titleStyle: LabelStyle
        public var subTitleStyle: LabelStyle
        public var buttonOneStyle: LabelStyle
        public var buttonTwoStyle: LabelStyle
        
        public var isCanClickBackground: Bool
        public var dialogBackgroundColor: UIColor
        public var dialogCornerRadius: CGFloat
        public var isShowSubtitle: Bool
        public var lineColor: UIColor
        
        /// 对话框距离左边屏幕间距
        public var dialogLeading: CGFloat
        /// title Top间距
        public var titleTopOffset: CGFloat
        /// subTitle Top间距
        public var subtitleTopOffset: CGFloat
        /// subTitle Bottom间距
        public var subtitleBottomOffset: CGFloat
        /// 按钮高度
        public var buttonHeight: CGFloat
        
        public init(
            titleStyle: LabelStyle = LabelStyle(text: "", textColor: .black, font: UIFont.systemFont(ofSize: 16, weight: .regular)),
            subTitleStyle: LabelStyle = LabelStyle(text: "", textColor: .black, font: UIFont.systemFont(ofSize: 14, weight: .regular)),
            buttonOneStyle: LabelStyle = LabelStyle(text: "", textColor: .black, font: UIFont.systemFont(ofSize: 16, weight: .regular)),
            buttonTwoStyle: LabelStyle = LabelStyle(text: "", textColor: .black, font: UIFont.systemFont(ofSize: 16, weight: .regular)),
            isCanClickBackground: Bool = true,
            dialogBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.3),
            dialogCornerRadius: CGFloat = 14,
            isShowSubtitle: Bool = true,
            lineColor: UIColor = UIColor.hexColor(color: "#333333").withAlphaComponent(0.1),
            dialogLeading: CGFloat = 50,
            titleTopOffset: CGFloat = 30,
            subtitleTopOffset: CGFloat = 20,
            subtitleBottomOffset: CGFloat = 20,
            buttonHeight: CGFloat = 50
        ) {
            self.titleStyle = titleStyle
            self.subTitleStyle = subTitleStyle
            self.buttonOneStyle = buttonOneStyle
            self.buttonTwoStyle = buttonTwoStyle
            self.isCanClickBackground = isCanClickBackground
            self.dialogBackgroundColor = dialogBackgroundColor
            self.dialogCornerRadius = dialogCornerRadius
            self.isShowSubtitle = isShowSubtitle
            self.lineColor = lineColor
            self.dialogLeading = dialogLeading
            self.titleTopOffset = titleTopOffset
            self.subtitleTopOffset = subtitleTopOffset
            self.subtitleBottomOffset = subtitleBottomOffset
            self.buttonHeight = buttonHeight
        }
    }
    
    // MARK: - UI Components
    public lazy var backgroundDimView: UIView = {
        let view = UIView()
        view.alpha = 0
        return view
    }()
    
    public lazy var dialogContainerView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return view
    }()
    
    public lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    public lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    public lazy var horizontalLine: UIView = {
        let view = UIView()
        return view
    }()
    
    public lazy var verticalLine: UIView = {
        let view = UIView()
        return view
    }()
    
    public lazy var buttonOne: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(onClickButtonOne), for: .touchUpInside)
        return button
    }()
    
    public lazy var buttonTwo: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(onClickButtonTwo), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private var dialogType: DialogType = .verticalOne
    private var config: Configuration = Configuration()
    private var onClickButtonBlock: ((_ btnIndex: Int) -> Void)?
    private var hideCompletion: (() -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // 添加背景遮罩
        addSubview(backgroundDimView)
        backgroundDimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 添加弹窗容器
        addSubview(dialogContainerView)
        
        // 添加内容视图到容器
        dialogContainerView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 添加背景点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onBackgroundTap))
        backgroundDimView.addGestureRecognizer(tapGesture)
    }
    
    private func updateContainerConstraints() {
        // 移除旧的约束
        dialogContainerView.snp.removeConstraints()
        
        dialogContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(config.dialogLeading)
            make.trailing.equalToSuperview().offset(-config.dialogLeading)
        }
    }
    
    private func setupLayout(for type: DialogType) {
        // 清除之前的约束
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // 添加公共组件
        contentView.addSubview(titleLabel)
        
        switch type {
        case .horizontalTwo:
            setupHorizontalTwoLayout()
        case .verticalOne:
            setupVerticalOneLayout()
        case .verticalTwo:
            setupVerticalTwoLayout()
        }
    }
    
    private func setupHorizontalTwoLayout() {
        // 水平方向两个按钮布局
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(buttonOne)
        contentView.addSubview(buttonTwo)
        contentView.addSubview(horizontalLine)
        contentView.addSubview(verticalLine)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(config.titleTopOffset)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 动态调整副标题高度
        let subtitleHeight: CGFloat = (config.isShowSubtitle && !config.subTitleStyle.text.isEmpty) ? 20 : 0
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(config.subtitleTopOffset)
            make.leading.trailing.equalTo(titleLabel)
            make.height.equalTo(subtitleHeight)
        }
        
        horizontalLine.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(config.subtitleBottomOffset)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        buttonOne.snp.makeConstraints { make in
            make.top.equalTo(horizontalLine.snp.bottom)
            make.leading.equalToSuperview()
            make.height.equalTo(config.buttonHeight)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        buttonTwo.snp.makeConstraints { make in
            make.top.equalTo(horizontalLine.snp.bottom)
            make.trailing.equalToSuperview()
            make.height.equalTo(config.buttonHeight)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.bottom.equalToSuperview()
        }
        
        verticalLine.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(horizontalLine.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalTo(1)
        }
    }
    
    private func setupVerticalOneLayout() {
        // 垂直方向一个按钮布局
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(horizontalLine)
        contentView.addSubview(buttonTwo)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(config.titleTopOffset)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 动态调整副标题高度
        let subtitleHeight: CGFloat = (config.isShowSubtitle && !config.subTitleStyle.text.isEmpty) ? 20 : 0
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(config.subtitleTopOffset)
            make.leading.trailing.equalTo(titleLabel)
            make.height.equalTo(subtitleHeight)
        }
        
        let topView = config.isShowSubtitle && !config.subTitleStyle.text.isEmpty ? subtitleLabel : titleLabel
        
        horizontalLine.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(config.subtitleBottomOffset)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        buttonTwo.snp.makeConstraints { make in
            make.top.equalTo(horizontalLine.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(config.buttonHeight)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupVerticalTwoLayout() {
        // 垂直方向两个按钮布局
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(horizontalLine)
        contentView.addSubview(buttonOne)
        contentView.addSubview(verticalLine) // 改为水平方向
        contentView.addSubview(buttonTwo)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(config.titleTopOffset)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 动态调整副标题高度
        let subtitleHeight: CGFloat = (config.isShowSubtitle && !config.subTitleStyle.text.isEmpty) ? 20 : 0
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(config.subtitleTopOffset)
            make.leading.trailing.equalTo(titleLabel)
            make.height.equalTo(subtitleHeight)
        }
        
        let topView = config.isShowSubtitle && !config.subTitleStyle.text.isEmpty ? subtitleLabel : titleLabel
        
        horizontalLine.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(config.subtitleTopOffset)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        buttonOne.snp.makeConstraints { make in
            make.top.equalTo(horizontalLine.snp.bottom)
            make.leading.equalToSuperview()
            make.height.equalTo(config.buttonHeight)
            make.width.equalToSuperview()
        }
        
        verticalLine.snp.makeConstraints { make in
            make.top.equalTo(buttonOne.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        buttonTwo.snp.makeConstraints { make in
            make.top.equalTo(verticalLine.snp.bottom)
            make.leading.equalToSuperview()
            make.height.equalTo(config.buttonHeight)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Animation Methods
    private func showDialog() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.backgroundDimView.alpha = 1
            self.dialogContainerView.alpha = 1
            self.dialogContainerView.transform = .identity
        }
    }
    
    private func hideDialog(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundDimView.alpha = 0
            self.dialogContainerView.alpha = 0
            self.dialogContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            completion()
        }
    }
    
    // MARK: - Actions
    @objc private func onBackgroundTap() {
        if config.isCanClickBackground {
            dismiss()
            onClickButtonBlock?(-1)
        }
    }
    
    @objc private func onClickButtonOne() {
        dismiss()
        onClickButtonBlock?(0)
    }
    
    @objc private func onClickButtonTwo() {
        dismiss()
        onClickButtonBlock?(1)
    }
    
    private func dismiss() {
        hideDialog { [weak self] in
            self?.removeFromSuperview()
            self?.hideCompletion?()
        }
    }
    
    // MARK: - Public Methods
    func setupData(type: DialogType,
                   config: Configuration,
                   onClickButtonBlock: ((_ btnIndex: Int) -> Void)? = nil) {
        self.dialogType = type
        self.config = config
        self.onClickButtonBlock = onClickButtonBlock
        
        // 更新容器约束
        updateContainerConstraints()
        
        // 更新UI
        updateUI()
        setupLayout(for: type)
        
        // 布局完成后显示动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.showDialog()
        }
    }
    
    private func updateUI() {
        backgroundDimView.backgroundColor = config.dialogBackgroundColor
        dialogContainerView.setCornerRadius(radius: config.dialogCornerRadius)
        titleLabel.text = config.titleStyle.text
        titleLabel.textColor = config.titleStyle.textColor
        titleLabel.font = config.titleStyle.font
        subtitleLabel.text = config.subTitleStyle.text
        subtitleLabel.textColor = config.subTitleStyle.textColor
        subtitleLabel.font = config.subTitleStyle.font
        horizontalLine.backgroundColor = config.lineColor
        verticalLine.backgroundColor = config.lineColor
        buttonOne.setTitle(config.buttonOneStyle.text, for: .normal)
        buttonOne.setTitleColor(config.buttonOneStyle.textColor, for: .normal)
        buttonOne.titleLabel?.font = config.buttonOneStyle.font
        buttonTwo.setTitle(config.buttonTwoStyle.text, for: .normal)
        buttonTwo.setTitleColor(config.buttonTwoStyle.textColor, for: .normal)
        buttonTwo.titleLabel?.font = config.buttonTwoStyle.font
        
        // 控制副标题显示
        subtitleLabel.isHidden = !config.isShowSubtitle || config.subTitleStyle.text.isEmpty
    }
    
    // MARK: - Show & Hide Methods
    public func show(in view: UIView?, completion: (() -> Void)? = nil) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.show(in: view, completion: completion)
            }
            return
        }
        
        guard let targetView = view ?? UIView.getKeyWindow() else {
            print("❌ Failed to show: No valid view or key window available")
            completion?()
            return
        }
        
        if self.superview != nil {
            self.removeFromSuperview()
        }
        
        // 设置完成回调
        self.hideCompletion = completion
        
        // 添加到目标视图
        targetView.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 强制布局更新后执行动画
        DispatchQueue.main.async {
            self.showDialog()
        }
    }
    
    public func hide(completion: (() -> Void)? = nil) {
        self.hideCompletion = completion
        dismiss()
    }
}

// MARK: - 便捷使用方法
public extension BaseDialogView {
    static func showDialog(type: DialogType,
                           config: BaseDialogView.Configuration,
                           in view: UIView? = nil,
                           onClickButtonBlock: ((_ btnIndex: Int) -> Void)? = nil) {
        let dialogView = BaseDialogView()
        dialogView.setupData(type: type, config: config, onClickButtonBlock: onClickButtonBlock)
        dialogView.show(in: view)
    }
}
