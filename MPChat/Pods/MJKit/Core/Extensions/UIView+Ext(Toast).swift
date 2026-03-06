//
//  UIView+Ext(Toast).swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit
import Foundation

// MARK: - ===== UIView (黑色提示弹窗) =====
public extension UIView {
    /// 弹出黑色提示弹窗
    @objc static func showTips(_ text: String,
                         duration: CGFloat = 3.0,
                         alignment: MJTipViewAlignment = .center,
                         config: MJTipViewConfiguration? = nil) {
        var newConfig = MJTipViewConfiguration()
        if let config = config {
            newConfig = config
        }
        MJTipView.show(text, duration: duration, alignment: alignment, config: newConfig)
    }
    
    /// 隐藏黑色提示弹窗
    @objc static func dismissTips() {
        MJTipView.dismiss()
    }
}

/// 提示框对齐方式
@objc public enum MJTipViewAlignment: Int {
    case center = 0
    case top = 1
    case bottom = 2
}

/// 配置类
@objcMembers
public class MJTipViewConfiguration: NSObject {
    /// 提示框与屏幕的间距（默认30px）
    public var spaceOfWindow: CGFloat = 30
    /// 文本与提示框的间距（默认15px）
    public var spaceOfTipView: CGFloat = 15
    /// top（导航栏高度）、bottom（Tabbar高度）加上offset高度
    public var offset: CGFloat = 20
    /// 背景色
    public var backgroundColor: UIColor = UIColor.black
    /// 文字颜色
    public var textColor: UIColor = UIColor.white
    /// 文本字体
    public var textfont: UIFont = UIFont.systemFont(ofSize: 16)
    /// 背景圆角
    public var cornerRadius: CGFloat = 10
    
    public override init() {
        super.init()
    }
    
    /// 初始化方法
    @objc public static func defaultConfiguration() -> MJTipViewConfiguration {
        return MJTipViewConfiguration()
    }
}

// MARK: - ===== MJTipView =====

@objcMembers
public class MJTipView: UIView {
    static let kMJTipViewTag: Int = 987
    static let kDefaultTime: TimeInterval = 3.0
    
    public var config: MJTipViewConfiguration = MJTipViewConfiguration()
    
    private var label: UILabel = UILabel()
    private var timeInterval: TimeInterval = 3.0
    private var currentAlignment: MJTipViewAlignment = .center
    private var currentContent: String = ""
    
    // MARK: - 公开方法
    
    /// 弹出提示框
    @objc public static func show(_ text: String,
                     duration: TimeInterval = 3.0,
                     alignment: MJTipViewAlignment = .center,
                     config: MJTipViewConfiguration = MJTipViewConfiguration()) {
        if text.isEmpty {
            return
        }
        let tipView = MJTipView()
        tipView.config = config
        tipView.showTipView(text: text, duration: duration, alignment: alignment)
    }
    
    @objc public static func show(_ text: String,
                     duration: TimeInterval,
                     alignment: MJTipViewAlignment) {
        show(text, duration: duration, alignment: alignment, config: MJTipViewConfiguration())
    }
    
    /// 移除弹窗
    @objc public static func dismiss() {
        let keyWindow = UIView.getKeyWindow()
        if let view = keyWindow?.viewWithTag(kMJTipViewTag), view.isKind(of: MJTipView.self) {
            view.removeFromSuperview()
        }
    }
    
    // MARK: - 内部实现
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc public func showTipView(text: String,
                            duration: TimeInterval,
                            alignment: MJTipViewAlignment) {
        DispatchQueue.main.async {
            self.currentContent = text
            self.timeInterval = duration <= 0 ? MJTipView.kDefaultTime : duration
            self.currentAlignment = alignment
            self.setupData()
            self.updateUI()
            
            if let keyWindow = UIView.getKeyWindow() {
                MJTipView.dismiss()
                
                self.tag = MJTipView.kMJTipViewTag
                keyWindow.addSubview(self)
            }
            
            if duration > 0 {
                DispatchQueue.main.asyncAfter(deadline: (.now() + self.timeInterval)) {
                    self.removeFromSuperview()
                }
            }
        }
    }
    
    // MARK: - 私有方法
    
    /// 初始化数据
    private func addObserver() {
        // 监听横竖屏切换
        NotificationCenter.default.addObserver(self, selector: #selector(orientChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    /// 屏幕旋转处理
    @objc private func orientChange() {
        self.updateUI()
    }
    
    private func setupData() {
        self.backgroundColor = config.backgroundColor
        self.layer.cornerRadius = config.cornerRadius
        self.clipsToBounds = true
        
        // 左右对齐
        let attStr = setTextLeftRight(text: self.currentContent)
        self.label.attributedText = attStr
        self.label.textAlignment = .left
        self.label.font = config.textfont
        self.label.numberOfLines = 0
        self.label.textColor = config.textColor
        self.addSubview(self.label)
    }
    
    /// 更新UI
    private func updateUI() {
        guard let supFrame = UIView.getKeyWindow()?.frame else {
            return
        }
        
        let screenH = UIScreen.main.bounds.height
        let navigationBarH: CGFloat = 44 // 默认导航栏高度
        let tabBarH: CGFloat = 49 // 默认TabBar高度
        
        let space = (config.spaceOfWindow + config.spaceOfTipView) * 2
        let size = CGSize(width: supFrame.size.width - space, height: screenH - space)
        let rect = textRect(text: currentContent, font: config.textfont, displaySize: size)
        
        // 默认居中
        let x = (supFrame.size.width - (rect.size.width + config.spaceOfTipView * 2)) / 2.0
        var y = (supFrame.size.height - (rect.size.height + config.spaceOfTipView * 2)) / 2.0
        
        switch self.currentAlignment {
        case .center:
            break
        case .top:
            y = navigationBarH + config.spaceOfWindow + config.offset
        case .bottom:
            y = supFrame.size.height - tabBarH - config.spaceOfWindow - (rect.size.height + config.spaceOfTipView * 2) - config.offset
        }
        
        let width = rect.size.width + config.spaceOfTipView * 2
        let height = rect.size.height + config.spaceOfTipView * 2
        
        self.frame = CGRect(x: max(x, config.spaceOfWindow),
                           y: y,
                           width: min(width, supFrame.size.width - config.spaceOfWindow * 2),
                           height: height)
        
        self.label.frame = CGRect(x: config.spaceOfTipView,
                                 y: config.spaceOfTipView,
                                 width: self.frame.size.width - config.spaceOfTipView * 2,
                                 height: self.frame.size.height - config.spaceOfTipView * 2)
    }
    
    /// 文本Rect
    private func textRect(text: String,
                          font: UIFont,
                          displaySize: CGSize) -> CGRect {
        let attribute = [NSAttributedString.Key.font: font]
        let options: NSStringDrawingOptions = [.truncatesLastVisibleLine, .usesLineFragmentOrigin, .usesFontLeading]
        let rect = (text as NSString).boundingRect(with: displaySize, options: options, attributes: attribute, context: nil)
        return rect
    }
    
    /// 左右对齐 (justified)
    private func setTextLeftRight(text: String) -> NSAttributedString {
        let attStrM = NSMutableAttributedString(string: text)
        let paragraphM = NSMutableParagraphStyle()
        paragraphM.alignment = .justified
        paragraphM.paragraphSpacing = 11.0
        paragraphM.paragraphSpacingBefore = 10.0
        paragraphM.firstLineHeadIndent = 0.0
        paragraphM.headIndent = 0.0
        let dic: [NSAttributedString.Key: Any] = [NSAttributedString.Key.paragraphStyle: paragraphM,
                                                  NSAttributedString.Key.underlineStyle: 0]
        attStrM.setAttributes(dic, range: NSRange(location: 0, length: attStrM.length))
        return attStrM.copy() as! NSAttributedString
    }
}
