//
//  UIView+Ext(PopView).swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit
import SnapKit

/* 使用示例
 let view = UIView()
 view.backgroundColor = .white
 view.snp.makeConstraints { make in
 make.height.equalTo(200)
 make.width.equalTo(MJ.kScreenWidth - 80)
 }
 
 // 1. 底部弹窗
 view.showAsBottomSheet()
 
 // 2. 中心弹窗 - 缩放动画（默认）
 view.showAsCenterDialog()
 
 // 3. 中心弹窗 - 从底部滑入
 view.showAsCenterDialogWithSlide()
 
 // 4. 自定义中心弹窗配置
 let customConfig = PopViewConfig(
 animationDuration: 0.25,
 springDamping: 0.7,
 initialSpringVelocity: 0.8,
 centerAnimationStyle: .slide
 )
 view.showAsCenterDialog(config: customConfig)
 */

// MARK: - PopView Configuration
public struct PopViewConfig {
    public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    public var animationDuration: TimeInterval = 0.3
    public var showZoomAnimation: Bool = true
    public var cornerRadius: CGFloat = 0
    public var contentInsets: UIEdgeInsets = .zero
    public var backgroundAnimation: Bool = true
    public var springDamping: CGFloat = 0.8 // 阻尼器
    public var initialSpringVelocity: CGFloat = 0.5
    public var animationOptions: UIView.AnimationOptions = [.curveEaseOut, .allowUserInteraction]
    public var centerAnimationStyle: CenterAnimationStyle = .scale // 中间弹窗动画样式
    
    public enum CenterAnimationStyle {
        case scale      // 缩放动画
        case slide      // 从底部滑入中间
    }
    
    public init(
        backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5),
        animationDuration: TimeInterval = 0.3,
        showZoomAnimation: Bool = true,
        cornerRadius: CGFloat = 0,
        contentInsets: UIEdgeInsets = .zero,
        backgroundAnimation: Bool = true,
        springDamping: CGFloat = 0.8,
        initialSpringVelocity: CGFloat = 0.5,
        animationOptions: UIView.AnimationOptions = [.curveEaseOut, .allowUserInteraction],
        centerAnimationStyle: CenterAnimationStyle = .scale
    ) {
        self.backgroundColor = backgroundColor
        self.animationDuration = animationDuration
        self.showZoomAnimation = showZoomAnimation
        self.cornerRadius = cornerRadius
        self.contentInsets = contentInsets
        self.backgroundAnimation = backgroundAnimation
        self.springDamping = springDamping
        self.initialSpringVelocity = initialSpringVelocity
        self.animationOptions = animationOptions
        self.centerAnimationStyle = centerAnimationStyle
    }
}

// MARK: - PopView Style
public enum PopViewStyle {
    case bottomSheet    // 底部弹窗
    case centerDialog   // 中心弹窗
    case custom         // 自定义位置
}

// MARK: - UIView PopView Extension
private var MJUIViewPopViewConfigKey: Void?
private var MJUIViewPopViewStyleKey: Void?
private var MJUIViewBackgroundViewKey: Void?
private var MJUIViewGestureDelegateKey: Void?

public extension UIView {
    /// PopView 配置
    var mjPopViewConfig: PopViewConfig {
        get {
            return objc_getAssociatedObject(self, &MJUIViewPopViewConfigKey) as? PopViewConfig ?? PopViewConfig()
        }
        set {
            objc_setAssociatedObject(self, &MJUIViewPopViewConfigKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// PopView 样式
    var mjPopViewStyle: PopViewStyle {
        get {
            return objc_getAssociatedObject(self, &MJUIViewPopViewStyleKey) as? PopViewStyle ?? .bottomSheet
        }
        set {
            objc_setAssociatedObject(self, &MJUIViewPopViewStyleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 背景视图
    var mjBackgroundView: UIView? {
        get {
            return objc_getAssociatedObject(self, &MJUIViewBackgroundViewKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &MJUIViewBackgroundViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 手势代理
    private var mjGestureDelegate: PopViewGestureDelegate? {
        get {
            return objc_getAssociatedObject(self, &MJUIViewGestureDelegateKey) as? PopViewGestureDelegate
        }
        set {
            objc_setAssociatedObject(self, &MJUIViewGestureDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public extension UIView {
    // MARK: - Public Methods
    
    /// 显示弹窗
    /// - Parameters:
    ///   - superview: 父视图，默认为 keyWindow
    ///   - style: 弹窗样式
    ///   - config: 弹窗配置
    func showAsPopView(
        in superview: UIView? = nil,
        style: PopViewStyle = .bottomSheet,
        config: PopViewConfig = PopViewConfig()
    ) {
        self.mjPopViewStyle = style
        self.mjPopViewConfig = config
        
        let targetSuperview = superview ?? getKeyWindow()
        guard let superview = targetSuperview else {
            print("==> 无法获取父视图！")
            return
        }
        
        // 防止重复添加
        if isAlreadyAdded(to: superview) {
            return
        }
        
        setupBackgroundView(in: superview)
        setupContentView(for: style)
        
        // 设置圆角
        if config.cornerRadius > 0 {
            self.layer.cornerRadius = config.cornerRadius
            self.layer.masksToBounds = true
        }
        
        // 执行显示动画
        showWithAnimation(style: style)
    }
    
    /// 隐藏弹窗
    func dismissPopView(completion: (() -> Void)? = nil) {
        hideWithAnimation(style: mjPopViewStyle) {
            self.mjBackgroundView?.removeFromSuperview()
            self.mjBackgroundView = nil
            self.mjGestureDelegate = nil
            self.removeFromSuperview()
            completion?()
        }
    }
    
    // MARK: - Private Methods
    
    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    private func isAlreadyAdded(to superview: UIView) -> Bool {
        return superview.subviews.contains { $0 == self }
    }
    
    private func setupBackgroundView(in superview: UIView) {
        let backgroundView = UIView()
        
        // 设置初始状态
        if mjPopViewConfig.backgroundAnimation {
            backgroundView.alpha = 0
            backgroundView.backgroundColor = mjPopViewConfig.backgroundColor
        } else {
            backgroundView.alpha = 1
            backgroundView.backgroundColor = mjPopViewConfig.backgroundColor
        }
        
        // 创建并保存代理
        mjGestureDelegate = PopViewGestureDelegate(popView: self)
        
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        tapGesture.delegate = mjGestureDelegate
        backgroundView.addGestureRecognizer(tapGesture)
        
        superview.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.mjBackgroundView = backgroundView
        superview.addSubview(self)
    }
    
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        // 由于代理已经过滤了点击内容视图的情况，
        // 能来到这里的一定是点击在背景上
        dismissPopView()
    }
    
    private func setupContentView(for style: PopViewStyle) {
        switch style {
        case .bottomSheet:
            setupBottomSheetLayout()
        case .centerDialog:
            setupCenterDialogLayout()
        case .custom:
            // 自定义布局由外部设置
            break
        }
    }
    
    private func setupBottomSheetLayout() {
        guard let _ = self.superview else { return }
        
        self.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(mjPopViewConfig.contentInsets.bottom)
        }
        
        // 初始位置：使用 transform 移动到屏幕外
        self.transform = CGAffineTransform(translationX: 0, y: MJ.kScreenHeight)
    }
    
    private func setupCenterDialogLayout() {
        guard let _ = self.superview else { return }
        
        self.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 根据动画样式设置初始状态
        switch mjPopViewConfig.centerAnimationStyle {
        case .scale:
            // 缩放动画：初始缩放为0
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.alpha = 0
        case .slide:
            // 滑动动画：初始位置在屏幕下方
            self.transform = CGAffineTransform(translationX: 0, y: MJ.kScreenHeight)
            self.alpha = 1
        }
    }
    
    private func showWithAnimation(style: PopViewStyle) {
        switch style {
        case .bottomSheet:
            showBottomSheetWithAnimation()
        case .centerDialog:
            showCenterDialogWithAnimation()
        case .custom:
            // 自定义动画由外部处理
            self.alpha = 1
        }
    }
    
    private func hideWithAnimation(style: PopViewStyle, completion: @escaping () -> Void) {
        switch style {
        case .bottomSheet:
            hideBottomSheetWithAnimation(completion: completion)
        case .centerDialog:
            hideCenterDialogWithAnimation(completion: completion)
        case .custom:
            // 自定义动画由外部处理
            self.alpha = 0
            completion()
        }
    }
    
    // MARK: - 动画实现
    private func showBottomSheetWithAnimation() {
        UIView.animate(
            withDuration: mjPopViewConfig.animationDuration,
            delay: 0,
            options: mjPopViewConfig.animationOptions) {
                self.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        
        UIView.animate(
            withDuration: mjPopViewConfig.animationDuration,
            delay: 0,
            usingSpringWithDamping: mjPopViewConfig.springDamping,
            initialSpringVelocity: mjPopViewConfig.initialSpringVelocity,
            options: mjPopViewConfig.animationOptions,
            animations: { [weak self] in
                guard let self = self else { return }
                
                // 背景色淡入
                if self.mjPopViewConfig.backgroundAnimation {
                    self.mjBackgroundView?.alpha = 1
                }
                
            },
            completion: nil
        )
    }
    
    private func hideBottomSheetWithAnimation(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: mjPopViewConfig.animationDuration,
            delay: 0,
            options: [.curveEaseIn],
            animations: { [weak self] in
                guard let self = self else { return }
                
                // 背景色淡出
                if self.mjPopViewConfig.backgroundAnimation {
                    self.mjBackgroundView?.alpha = 0
                }
                
                // 内容视图向下方滑出
                self.transform = CGAffineTransform(translationX: 0, y: MJ.kScreenHeight)
            },
            completion: { _ in
                completion()
            }
        )
    }
    
    private func showCenterDialogWithAnimation() {
        if mjPopViewConfig.centerAnimationStyle == .slide {
            UIView.animate(
                withDuration: mjPopViewConfig.animationDuration,
                delay: 0,
                options: mjPopViewConfig.animationOptions) {
                    self.transform = CGAffineTransform(translationX: 0, y: 0)
                }
        }
        
        UIView.animate(
            withDuration: mjPopViewConfig.animationDuration,
            delay: 0,
            usingSpringWithDamping: mjPopViewConfig.springDamping,
            initialSpringVelocity: mjPopViewConfig.initialSpringVelocity,
            options: mjPopViewConfig.animationOptions,
            animations: { [weak self] in
                guard let self = self else { return }
                
                // 背景色淡入
                if self.mjPopViewConfig.backgroundAnimation {
                    self.mjBackgroundView?.alpha = 1
                }
                
                // 根据动画样式执行不同的动画
                if self.mjPopViewConfig.centerAnimationStyle == .scale {
                    // 缩放动画
                    self.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.alpha = 1
                }
            },
            completion: nil
        )
    }
    
    private func hideCenterDialogWithAnimation(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: mjPopViewConfig.animationDuration,
            delay: 0,
            options: [.curveEaseIn],
            animations: { [weak self] in
                guard let self = self else { return }
                
                // 背景色淡出
                if self.mjPopViewConfig.backgroundAnimation {
                    self.mjBackgroundView?.alpha = 0
                }
                
                // 根据动画样式执行不同的隐藏动画
                switch self.mjPopViewConfig.centerAnimationStyle {
                case .scale:
                    // 缩放隐藏
                    self.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                    self.alpha = 0
                case .slide:
                    // 滑动隐藏：滑到底部
                    self.transform = CGAffineTransform(translationX: 0, y: MJ.kScreenHeight)
                }
            },
            completion: { _ in
                completion()
            }
        )
    }
}

// MARK: - Convenience Methods
public extension UIView {
    /// 便捷方法：显示底部弹窗
    func showAsBottomSheet(
        in superview: UIView? = nil,
        config: PopViewConfig = PopViewConfig()
    ) {
        showAsPopView(in: superview, style: .bottomSheet, config: config)
    }
    
    /// 便捷方法：显示中心弹窗（缩放动画）
    func showAsCenterDialog(
        in superview: UIView? = nil,
        config: PopViewConfig = PopViewConfig()
    ) {
        showAsPopView(in: superview, style: .centerDialog, config: config)
    }
    
    /// 便捷方法：显示中心弹窗（从底部滑入）
    func showAsCenterDialogWithSlide(
        in superview: UIView? = nil,
        config: PopViewConfig = PopViewConfig()
    ) {
        var slideConfig = config
        slideConfig.centerAnimationStyle = .slide
        showAsPopView(in: superview, style: .centerDialog, config: slideConfig)
    }
}

// MARK: - PopView Gesture Delegate
private class PopViewGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    weak var popView: UIView?
    
    init(popView: UIView) {
        self.popView = popView
        super.init()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let popView = popView,
              let backgroundView = popView.mjBackgroundView else { return true }
        
        // 获取触摸点
        let touchPoint = touch.location(in: backgroundView)
        
        // 转换坐标到内容视图
        let pointInContentView = popView.convert(touchPoint, from: backgroundView)
        
        // 如果点击在内容视图上，不接收手势（返回false）
        // 只有点击在背景上才接收手势（返回true）
        let value = !popView.bounds.contains(pointInContentView)
        return value
    }
}
