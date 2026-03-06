//
//  UIView+Ext.swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

public extension UIView {
    // MARK: 移除 subviews
    /// 移除 subviews
    func removeAllSubviews() {
        self.subviews.forEach {
            if let stackView = $0 as? UIStackView {
                stackView.removeAllArrangedSubviewsCompletely()
            } else {
                $0.removeAllSubviews()
            }
            $0.removeFromSuperview()
        }
    }
    
    // MARK: 设置圆角
    /// 设置圆角
    func setCornerRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    /// 设置圆角
    func setCornerRadius(conrners: UIRectCorner,
                         radius: CGFloat) {
        var tempCorners: CACornerMask = CACornerMask()
        if conrners.contains(.topLeft) {
            tempCorners.insert(.layerMinXMinYCorner)
        }
        if conrners.contains(.topRight) {
            tempCorners.insert(.layerMaxXMinYCorner)
        }
        if conrners.contains(.bottomLeft) {
            tempCorners.insert(.layerMinXMaxYCorner)
        }
        if conrners.contains(.bottomRight) {
            tempCorners.insert(.layerMaxXMaxYCorner)
        }
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = tempCorners
        self.layer.masksToBounds = true
    }
    
    // MARK: 添加阴影
    /// 添加阴影
    func addShadow(color: UIColor,
                   shadowOffset: CGSize = CGSize(width: 0, height: 0),
                   shadowRadius: CGFloat = 5,
                   shadowOpacity: Float = 0.3,
                   radius: CGFloat = 0) {
        // 注意背景色不能是clear，否则效果
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = shadowOpacity
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = false
    }
    
    // MARK: 设置边框颜色
    /// 设置边框颜色
    func setBorderColor(borderWidth: CGFloat,
                        borderColor: UIColor) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
    
    // MARK: 设置 subviews 边框随机颜色
    /// 设置 subviews 边框随机颜色
    func setBorderRandomColor(borderWidth: CGFloat = 0.5) {
        self.setBorderColor(borderWidth: borderWidth, borderColor: UIColor.randomColor())
        self.subviews.forEach {
            $0.setBorderRandomColor(borderWidth: borderWidth)
        }
    }
    
    // MARK: 渐变色
    enum GradientPointType: Int {
        case topToBottom = 0            // 上到下
        case leftToRight = 1            // 左到右
        case topLeftToBottomRight = 2   // 左上到右下
        case bottomLeftToTopRight = 3   // 左下到右上
    }
    
    func getGradientPoints(type: GradientPointType) -> (startPoint: CGPoint, endPoint: CGPoint) {
        var startPoint: CGPoint = CGPoint(x: 0.5, y: 0)
        var endPoint: CGPoint = CGPoint(x: 0.5, y: 1)
        
        switch type {
        case .topToBottom:
            break
        case .leftToRight:
            startPoint = CGPoint(x: 0, y: 0.5)
            endPoint = CGPoint(x: 1, y: 0.5)
            break
        case .topLeftToBottomRight:
            startPoint = CGPoint(x: 0, y: 0)
            endPoint = CGPoint(x: 1, y: 1)
            break
        case .bottomLeftToTopRight:
            startPoint = CGPoint(x: 0, y: 1)
            endPoint = CGPoint(x: 1, y: 0)
            break
        }
        
        return (startPoint, endPoint)
    }
    
    /// 移除渐变色
    func removeGradient() {
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
    }
    
    func getGradientLayer() -> CAGradientLayer? {
        let gradientLayer: CAGradientLayer? = self.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer
        return gradientLayer
    }
    
    /// 渐变颜色数组动画变化
    func animateGradientColors(gradientLayer: CAGradientLayer,
                               colors: [UIColor]) {
        var currentColors = colors
        
        // 创建一个定时器来更新颜色顺序
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            // 动画渐变颜色
            let colorAnimation = CABasicAnimation(keyPath: "colors")
            colorAnimation.fromValue = currentColors.map { $0.cgColor }
            
            // 更新颜色顺序
            let firstColor = currentColors.removeLast()
            currentColors.insert(firstColor, at: 0)
            colorAnimation.toValue = currentColors.map { $0.cgColor }
            colorAnimation.duration = 1.0 // 动画持续时间
            colorAnimation.autoreverses = false // 不反向播放
            colorAnimation.fillMode = .forwards
            colorAnimation.isRemovedOnCompletion = false
            
            // 设置新的颜色
            gradientLayer.colors = currentColors.map { $0.cgColor }
            gradientLayer.add(colorAnimation, forKey: "colorAnimation")
        }
        
        // 初始设置渐变颜色
        gradientLayer.colors = currentColors.map { $0.cgColor }
    }
    
    // MARK: 设置背景渐变色
    /// 设置背景渐变色
    func setGradient(colors: [UIColor],
                     rect: CGRect = .zero,
                     gradientType: GradientPointType = .topToBottom) {
        
        var startPoint: CGPoint = CGPoint(x: 0.5, y: 0)
        var endPoint: CGPoint = CGPoint(x: 0.5, y: 1)
        let result = getGradientPoints(type: gradientType)
        startPoint = result.startPoint
        endPoint = result.endPoint
        
        setGradient(colors: colors, rect: rect, startPoint: startPoint, endPoint: endPoint)
    }
    
    /// 设置背景渐变色
    func setGradient(colors: [UIColor],
                     rect: CGRect = .zero,
                     startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
                     endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        
        // 移除之前的渐变图层，避免重复添加
        removeGradient()
        // 创建渐变图层
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        if rect.size.width > 0 {
            gradientLayer.frame = rect
        }
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        // 将渐变图层添加到按钮的图层中
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: 设置边框渐变色
    /// 设置边框渐变色
    func setGradientBorder(colors: [UIColor],
                           lineWidth: CGFloat = 1.0,
                           cornerRadius: CGFloat = 0.0,
                           gradientType: GradientPointType = .topToBottom) {
        var startPoint: CGPoint = CGPoint(x: 0.5, y: 0)
        var endPoint: CGPoint = CGPoint(x: 0.5, y: 1)
        let result = getGradientPoints(type: gradientType)
        startPoint = result.startPoint
        endPoint = result.endPoint
        
        setGradientBorder(colors: colors, lineWidth: lineWidth, cornerRadius: cornerRadius, startPoint: startPoint, endPoint: endPoint)
    }
    
    /// 设置边框渐变色
    func setGradientBorder(colors: [UIColor],
                           lineWidth: CGFloat = 1.0,
                           cornerRadius: CGFloat = 0.0,
                           startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
                           endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        // 移除旧的层
        removeGradient()
        
        // 创建一个形状层来定义边框的路径
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = lineWidth
        // 缩小绘制范围
        let insetBounds = self.bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        shapeLayer.path = UIBezierPath(roundedRect: insetBounds, cornerRadius: cornerRadius).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        
        // 创建渐变层
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        // 将形状层作为渐变层的掩码
        gradientLayer.mask = shapeLayer
        // 将渐变层添加到视图的层
        self.layer.addSublayer(gradientLayer)
    }
    
    // MARK: 获取控件截图
    /// 获取控件截图
    func screenshotsImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }
    }
    
    /// 获取控件截图 (顶部预留间距)
    func screenshotsImage(topOffset: CGFloat) -> UIImage {
        var rect = self.bounds
        rect.origin.y = -topOffset
        rect.size.height += topOffset
        //
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }
    }
    
    // MARK: 旋转指定角度
    /// 旋转角度（0到360）
    func rotateAngle(degrees: CGFloat,
                     duration: TimeInterval = 0.3) {
        let radians = degrees * .pi / 180
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(rotationAngle: radians)
        }
    }
    
    // MARK: 毛玻璃（高斯模糊）
    /// 添加毛玻璃（高斯模糊）
    func applyBlurOverlay(effectStyle: UIBlurEffect.Style = .light, overlayAlpha: CGFloat = 1.0) {
        // 移除现有的模糊效果视图
        self.subviews
            .compactMap { $0 as? UIVisualEffectView }
            .forEach { $0.removeFromSuperview() }
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = overlayAlpha
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(blurEffectView)
        self.sendSubviewToBack(blurEffectView)
    }
    
    // MARK: 抖动动画
    /// 抖动动画
    func shakeAnimation(width: CGFloat = 8,
                        values: [Any]? = nil,
                        duration: CGFloat = 0.3,
                        repeatCount: Float = 2) {
        let keyAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        if let values = values {
            keyAnimation.values = values
        } else {
            keyAnimation.values = [-width, 0, width, 0, -width, 0, width, 0]
        }
        keyAnimation.duration = duration
        keyAnimation.repeatCount = repeatCount
        keyAnimation.isRemovedOnCompletion = true
        //
        self.layer.add(keyAnimation, forKey: "shake")
    }
    
    // MARK: 旋转动画
    /// 旋转动画, 默认顺时针
    func startRotationAnimation(repeatCount: Bool = true,
                                duration: TimeInterval = 1,
                                clockwise: Bool = true) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = clockwise ? CGFloat.pi * 2.0 : -CGFloat.pi * 2.0
        rotationAnimation.duration = duration
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = repeatCount ? MAXFLOAT : 1
        //
        self.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    // MARK: 移除所有动画
    /// 移除所有动画
    func removeAnimations() {
        self.layer.removeAllAnimations()
    }
}

// MARK: - ===== UIView (System) =====
public extension UIView {
    /// 映射
    func getClassOfView() -> AnyClass {
        let viewType = type(of: self)
        return viewType
    }
    
    // MARK: Nib
    /// Xib初始化
    static func loadFromNib(_ nibName: String? = nil) -> Self {
        let loadName = nibName ?? "\(self)"
        // 尝试加载 Nib
        guard let loadedView = Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)?.first as? Self else {
            fatalError("Could not load nib named \(loadName)") // 处理加载失败的情况
        }
        return loadedView
    }
    
    static func getNib() -> UINib {
        let classStr: String = NSStringFromClass(self)
        if let nibName: String = (classStr as NSString).components(separatedBy: ".").last {
            return UINib(nibName: nibName, bundle: nil)
        }
        return UINib()
    }
}

public extension UIView {
    // MARK: 状态栏颜色
    /// 设置状态栏颜色
    static func setStatusBarBGColor(color: UIColor) {
        if #available(iOS 13.0, *) {
            let tag = 987654321
            if let keyWindow = UIView.getKeyWindow() {
                if let statusBar = keyWindow.viewWithTag(tag) {
                    statusBar.backgroundColor = color
                } else {
                    let statusBar = UIView(frame: keyWindow.windowScene?.statusBarManager?.statusBarFrame ?? .zero)
                    if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
                        statusBar.backgroundColor = color
                    }
                    statusBar.tag = tag
                    keyWindow.addSubview(statusBar)
                }
            }
        } else {
            if let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
                    statusBar.backgroundColor = color
                }
            }
        }
    }
    
    /// 获取状态栏颜色
    static func getStatusBarBGColor() -> UIColor? {
        if #available(iOS 13.0, *) {
            let tag = 987654321
            if let keyWindow = UIView.getKeyWindow() {
                if let statusBar = keyWindow.viewWithTag(tag) {
                    return statusBar.backgroundColor
                } else {
                    let statusBar = UIView(frame: keyWindow.windowScene?.statusBarManager?.statusBarFrame ?? .zero)
                    return statusBar.backgroundColor
                }
            }
            return nil
        } else {
            if let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                return statusBar.backgroundColor
            }
            return nil
        }
    }
    
    // MARK: 获取 keyWindow
    /// 获取 keyWindow
    static func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    // MARK: 获取当前 ViewController
    /// 获取当前 ViewController
    static func getCurrentViewController() -> UIViewController {
        var topViewController: UIViewController?
        // 获取主窗口的根视图控制器
        if let keyWindow = UIView.getKeyWindow() {
            topViewController = keyWindow.rootViewController
        }
        // 遍历获取顶层视图控制器
        while true {
            if let presentedVC = topViewController?.presentedViewController {
                topViewController = presentedVC
            } else if let navController = topViewController as? UINavigationController {
                topViewController = navController.topViewController
            } else if let tabController = topViewController as? UITabBarController {
                topViewController = tabController.selectedViewController
            } else {
                break
            }
        }
        // 返回找到的视图控制器或一个新的 UIViewController 实例
        return topViewController ?? UIViewController()
    }
    
    // MARK: 返回指定页面
    /// 返回指定页面
    static func backToViewController(naVC: UINavigationController,
                                     toVC: UIViewController,
                                     completedBlock: ((_ vc: UIViewController) -> Void)? = nil,
                                     notExistBlock: (() -> Void)? = nil) {
        var isExist: Bool = false
        var vcArr: Array<UIViewController> = Array<UIViewController>()
        for vc: UIViewController in naVC.viewControllers {
            vcArr.append(vc)
            if vc.isKind(of: toVC.classForCoder) {
                completedBlock?(vc)
                isExist = true
                break
            }
        }
        if isExist {
            naVC.setViewControllers(vcArr, animated: true)
        } else {
            // 不存在目标VC
            if let block = notExistBlock {
                block()
            } else {
                naVC.pushViewController(toVC, animated: true)
            }
        }
    }
    
    // MARK: button 倒计时
    /// button 倒计时
    static func startCountDown(timeOut: Int,
                               normalText: String,
                               normalTextColor: UIColor?,
                               runTextColor: UIColor?,
                               runLeftText: String = "",
                               runRightText: String = "s",
                               btn: UIButton) {
        btn.isHidden = true
        let newBtn = UIButton(type: .custom)
        newBtn.translatesAutoresizingMaskIntoConstraints = false
        newBtn.titleLabel?.font = btn.titleLabel?.font
        newBtn.titleLabel?.text = btn.titleLabel?.text
        newBtn.titleLabel?.textColor = btn.titleLabel?.textColor
        btn.superview?.addSubview(newBtn)
        NSLayoutConstraint.activate([
            newBtn.topAnchor.constraint(equalTo: btn.topAnchor),
            newBtn.leadingAnchor.constraint(equalTo: btn.leadingAnchor),
            newBtn.trailingAnchor.constraint(equalTo: btn.trailingAnchor),
            newBtn.bottomAnchor.constraint(equalTo: btn.bottomAnchor)
        ])
        // 倒计时时间
        var timeout = timeOut
        let queue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        let _timer: DispatchSource = DispatchSource.makeTimerSource(flags: [], queue: queue) as! DispatchSource
        _timer.schedule(wallDeadline: .now(), repeating: .seconds(1))
        // 每秒执行
        _timer.setEventHandler(handler: { () -> Void in
            if timeout <= 0 {
                // 倒计时结束，关闭
                _timer.cancel()
                DispatchQueue.main.sync(execute: { () -> Void in
                    newBtn.setTitle(normalText, for: .normal)
                    if let normalTextColor = normalTextColor {
                        newBtn.setTitleColor( normalTextColor, for: .normal)
                    }
                    newBtn.isEnabled = true
                    newBtn.removeFromSuperview()
                    btn.isHidden = false
                })
            } else {
                // 正在倒计时
                let seconds = timeout
                DispatchQueue.main.sync(execute: { () -> Void in
                    let str = String(describing: seconds)
                    newBtn.setTitle("\(runLeftText)\(str)\(runRightText)", for: .normal)
                    if let runTextColor = runTextColor {
                        newBtn.setTitleColor( runTextColor, for: .normal)
                    }
                    newBtn.isEnabled = false
                })
                timeout -= 1
            }
        })
        _timer.resume()
    }
    
    // MARK: 判断subViews中是否存在某类型的View
    /// 是否存在View
    static func isExist(supView: UIView,
                        viewClass: AnyClass) -> Bool {
        var isExist: Bool = false
        for subView in supView.subviews {
            if subView.isKind(of: viewClass) {
                isExist = true
                break
            }
        }
        return isExist
    }
}

// MARK: ========== 初始化控件 ==========
public extension UIView {
    // MARK: 初始化 UIView
    /// 初始化 UIView
    static func create(backgroundColor: UIColor? = nil,
                       tag: Int = 0) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = backgroundColor
        view.tag = tag
        return view
    }
}

public extension UILabel {
    // MARK: 初始化 UILabel
    /// 初始化 UILabel
    static func create(text: String? = nil,
                       textColor: UIColor? = nil,
                       font: UIFont? = nil,
                       numberOfLines: Int = 1,
                       textAlignment: NSTextAlignment = .left,
                       tag: Int = 0) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        if let textColor = textColor {
            label.textColor = textColor
        }
        if let font = font {
            label.font = font
        }
        label.numberOfLines = numberOfLines
        label.textAlignment = textAlignment
        label.tag = tag
        return label
    }
}

public extension UIButton {
    // MARK: 初始化 UIButton
    /// 初始化 UIButton
    static func create(buttonType: UIButton.ButtonType = .system,
                       text: String? = nil,
                       textColor: UIColor? = nil,
                       bgColor: UIColor? = nil,
                       cornerRadius: CGFloat = 0,
                       font: UIFont? = nil,
                       iconName: String? = nil,
                       tag: Int = 0,
                       enlargeInset: CGFloat = 0,
                       upInsideHandle: ((_ button: UIButton) -> Void)? = nil) -> UIButton {
        let button = UIButton(type: buttonType)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(text, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        if let font = font {
            button.titleLabel?.font = font
        }
        if let iconName = iconName {
            button.setImage(UIImage(named: iconName), for: .normal)
        }
        if let bgColor = bgColor {
            button.backgroundColor = bgColor
        }
        button.tag = tag
        button.setCornerRadius(radius: cornerRadius)
        button.touchExtendInset = enlargeInset
        button.setHandle(event: .touchUpInside) { button in
            if let block = upInsideHandle {
                block(button)
            }
        }
        return button
    }
}

public extension UIImageView {
    // MARK: 初始化 UIImageView
    /// 初始化 UIImageView
    static func create(iconName: String? = nil,
                       tag: Int = 0) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        if let iconName = iconName {
            imageView.image = UIImage(named: iconName)
        }
        imageView.tag = tag
        
        return imageView
    }
}

public extension UITextField {
    // MARK: 初始化 UITextField
    /// 初始化 UITextField
    static func create(text: String? = nil,
                       textColor: UIColor? = nil,
                       font: UIFont? = nil,
                       leftSpac: CGFloat = 10,
                       tag: Int = 0) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.text = text
        tf.textColor = textColor
        if let font = font {
            tf.font = font
        }
        tf.clearButtonMode = .whileEditing
        tf.setTextLeftSpac(leftSpac)
        tf.tag = tag
        return tf
    }
    
    /// 设置Text左边间距
    func setTextLeftSpac(_ spac: CGFloat) {
        let leftView = UIView()
        leftView.frame = CGRectMake(0, 0, spac, 1)
        self.leftViewMode = .always
        self.leftView = leftView
    }
}

public extension UITextView {
    // MARK: 初始化 UITextView
    /// 初始化 UITextView
    static func create(text: String? = nil,
                       textColor: UIColor? = nil,
                       font: UIFont? = nil,
                       leftTextSpac: CGFloat = 10,
                       tag: Int = 0) -> UITextView {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = text
        tv.textColor = textColor
        if let font = font {
            tv.font = font
        }
        tv.tag = tag
        return tv
    }
}

public extension UIStackView {
    // MARK: 初始化 UIStackView
    /// 初始化 UIStackView
    static func create(axis: NSLayoutConstraint.Axis,
                       alignment: UIStackView.Alignment = .fill,
                       distribution: UIStackView.Distribution = .fill,
                       spacing: CGFloat = 0.0) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
        return stackView
    }
}

// MARK: ===== UIDatePicker =====
public extension UIDatePicker {
    // MARK: 修改 UIDatePicker 中间选中区域的背景色
    /// 修改 UIDatePicker 中间选中区域的背景色
    func setSelectedViewBgColor(_ color: UIColor) {
        for subView in self.subviews {
            for inSubView in subView.subviews {
                if inSubView.frame.height < 50 {
                    inSubView.backgroundColor = color
                    break
                }
            }
        }
    }
}

// MARK: ===== UIAlertAction =====
extension UIAlertAction {
    // MARK: 获取所有的属性
    /// 获取所有的属性
    static var propertyNames: [String] {
        var outCount: UInt32 = 0
        guard let ivars = class_copyIvarList(self, &outCount) else {
            return []
        }
        var result = [String]()
        let count = Int(outCount)
        for i in 0..<count {
            let pro: Ivar = ivars[i]
            guard let ivarName = ivar_getName(pro) else {
                continue
            }
            guard let name = String(utf8String: ivarName) else {
                continue
            }
            result.append(name)
        }
        return result
    }
    
    // MARK: 是否存在某个属性
    /// 是否存在某个属性
    func isPropertyExisted(_ propertyName: String) -> Bool {
        for name in UIAlertAction.propertyNames {
            if name == propertyName {
                return true
            }
        }
        return false
    }
    
    // MARK: 设置自定义颜色
    /// 设置自定义颜色
    func setTextColor(_ color: UIColor) {
        let key = "_titleTextColor"
        guard isPropertyExisted(key) else {
            return
        }
        self.setValue(color, forKey: key)
    }
}

// MARK: - ===== UIView (Frame) =====
public extension UIView {
    var origin: CGPoint {
        set {
            self.frame.origin = newValue
        }
        get {
            self.frame.origin
        }
    }
    var size: CGSize {
        set {
            self.frame.size = newValue
        }
        get {
            self.frame.size
        }
    }
    var width: CGFloat {
        set {
            self.frame.size.width = newValue
        }
        get {
            self.frame.size.width
        }
    }
    var height: CGFloat {
        set {
            self.frame.size.height = newValue
        }
        get {
            self.frame.size.height
        }
    }
    /// 上
    var top: CGFloat {
        set {
            self.frame.origin.y = newValue
        }
        get {
            self.frame.origin.y
        }
    }
    /// 左
    var left: CGFloat {
        set {
            self.frame.origin.x = newValue
        }
        get {
            self.frame.origin.x
        }
    }
    /// 下
    var bottom: CGFloat {
        set {
            self.frame.origin.y = newValue - self.frame.size.height
        }
        get {
            self.frame.origin.y + self.frame.size.height
        }
    }
    /// 右
    var right: CGFloat {
        set {
            self.frame.origin.x += newValue - (self.frame.origin.x + self.frame.size.width)
        }
        get {
            self.frame.origin.x + self.frame.size.width
        }
    }
    /// 左上
    var topLeft: CGPoint {
        return CGPoint(x: self.frame.origin.x, y: self.frame.origin.y)
    }
    /// 左下
    var bottomLeft: CGPoint {
        let x = self.frame.origin.x
        let y = self.frame.origin.y + self.frame.size.height
        return CGPoint(x: x, y: y)
    }
    /// 右上
    var topRight: CGPoint {
        let x = self.frame.origin.x + self.frame.size.width
        let y = self.frame.origin.y
        return CGPoint(x: x, y: y)
    }
    /// 右下
    var bottomRight: CGPoint {
        let x = self.frame.origin.x + self.frame.size.width
        let y = self.frame.origin.y + self.frame.size.height
        return CGPoint(x: x, y: y)
    }
    /// X 加减
    func setX(_ value: CGFloat) {
        var frame = self.frame
        frame.origin.x += value
        self.frame = frame
    }
    /// Y 加减
    func setY(_ value: CGFloat) {
        var frame = self.frame
        frame.origin.y += value
        self.frame = frame
    }
}

// MARK: - UIStackView
public extension UIStackView {
    func removeAllArrangedSubviewsCompletely() {
        let arranged = arrangedSubviews
        arranged.forEach { view in
            self.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

// MARK: - UIView 点击手势
private var tapGestureKey: UInt8 = 0
private var tapActionClosureKey: UInt8 = 0

public extension UIView {
    /// 添加点击手势
    func addTapGesture(target: Any?,
                       action: Selector) {
        // 1. 开启用户交互（UIView 默认 isUserInteractionEnabled = false）
        isUserInteractionEnabled = true
        
        // 2. 移除已存在的点击手势（避免重复添加导致多次响应）
        if let oldGesture = objc_getAssociatedObject(self, &tapGestureKey) as? UITapGestureRecognizer {
            removeGestureRecognizer(oldGesture)
        }
        // 3. 创建新的点击手势并关联
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tapGesture)
        
        // 4. 保存手势到关联对象（用于后续移除）
        objc_setAssociatedObject(self, &tapGestureKey, tapGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// 添加点击手势
    func addTapAction(_ action: @escaping (() -> Void)) {
        // 1. 开启用户交互
        isUserInteractionEnabled = true
        
        // 2. 移除已存在的点击手势
        if let oldGesture = objc_getAssociatedObject(self, &tapGestureKey) as? UITapGestureRecognizer {
            removeGestureRecognizer(oldGesture)
        }
        
        // 3. 保存闭包到关联对象（分类无法直接添加存储属性，需用关联对象）
        objc_setAssociatedObject(self, &tapActionClosureKey, action, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        
        // 4. 创建手势并绑定内部处理方法
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapAction))
        addGestureRecognizer(tapGesture)
        
        // 5. 保存手势到关联对象
        objc_setAssociatedObject(self, &tapGestureKey, tapGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc private func handleTapAction() {
        // 取出关联的闭包并执行
        if let action = objc_getAssociatedObject(self, &tapActionClosureKey) as? () -> Void {
            action()
        }
    }
    
    /// 移除点击事件
    func removeTapGesture() {
        if let tapGesture = objc_getAssociatedObject(self, &tapGestureKey) as? UITapGestureRecognizer {
            removeGestureRecognizer(tapGesture)
            // 清空关联对象
            objc_setAssociatedObject(self, &tapGestureKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(self, &tapActionClosureKey, nil, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
