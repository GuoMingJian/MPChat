//
//  UIButton+Extension.swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

// MARK: -
public protocol MJBlockProtocol {
    associatedtype T
    
    typealias MJCallBack = ((T?) -> ())
    
    var mjCallBack: MJCallBack? {
        get
        set
    }
}

// MARK: -
public extension UIButton {
    func setHandle(event: UIControl.Event = .touchUpInside,
                   callBlock: ((_ button: UIButton) -> Void)? = nil) {
        self.mjCallBack = { button in
            if let block = callBlock, let button = button {
                block(button)
            }
        }
        self.addTarget(self, action: #selector(self.buttonAction), for: event)
    }
}

private var MJButtonCallBackKey: Void?
extension UIButton: MJBlockProtocol {
    public typealias T = UIButton
    public var mjCallBack: MJCallBack? {
        get {
            return mj_getAssociatedObject(self, &MJButtonCallBackKey)
        }
        set {
            mj_setRetainedAssociatedObject(self, &MJButtonCallBackKey, newValue)
        }
    }
    
    @objc internal func buttonAction(_ button: UIButton) {
        self.mjCallBack?(button)
    }
}

// MARK: ===== 扩大点击范围 =====
public extension UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 如果按钮不可用，直接调用父类方法
        if isHidden || !isEnabled {
            return super.point(inside: point, with: event)
        }
        
        // 选择使用哪个扩展
        let insets: UIEdgeInsets
        if self.touchExtendEdgeInsets != .zero {
            insets = self.touchExtendEdgeInsets
        } else {
            let offset: CGFloat = self.touchExtendInset
            insets = UIEdgeInsets(top: -offset, left: -offset, bottom: -offset, right: -offset)
        }
        
        // 计算点击区域
        var hitFrame = bounds.inset(by: insets)
        hitFrame.size.width = max(hitFrame.size.width, 0)
        hitFrame.size.height = max(hitFrame.size.height, 0)
        
        return hitFrame.contains(point)
    }
}

private var MJUIButtonExpandEdgeInsetsKey: Void?
private var MJUIButtonExtendInsetKey: Void?

public extension UIButton {
    /// 扩大点击区域 UIEdgeInsets
    var touchExtendEdgeInsets: UIEdgeInsets {
        get {
            if let value = objc_getAssociatedObject(self, &MJUIButtonExpandEdgeInsetsKey) as? NSValue {
                var edgeInsets: UIEdgeInsets = .zero
                value.getValue(&edgeInsets)
                return edgeInsets
            }
            return .zero
        }
        set {
            let value = NSValue(uiEdgeInsets: newValue)
            objc_setAssociatedObject(self, &MJUIButtonExpandEdgeInsetsKey, value, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    /// 扩大点击区域 CGFloat
    var touchExtendInset: CGFloat {
        get {
            return objc_getAssociatedObject(self, &MJUIButtonExtendInsetKey) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, &MJUIButtonExtendInsetKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
