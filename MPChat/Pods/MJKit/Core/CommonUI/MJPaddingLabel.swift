//
//  MJPaddingLabel.swift
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

// MARK: - 具有内边距的Label
public class MJPaddingLabel : UILabel {
    public var paddingLeft: CGFloat {
        get { return padding.left }
        set { padding.left = newValue }
    }
    
    public var paddingRight: CGFloat {
        get { return padding.right }
        set { padding.right = newValue }
    }
    
    public var paddingTop: CGFloat {
        get { return padding.top }
        set { padding.top = newValue }
    }
    
    public var paddingBottom: CGFloat {
        get { return padding.bottom }
        set { padding.bottom = newValue }
    }
    
    public var padding: UIEdgeInsets = .zero {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    public convenience init(padding: UIEdgeInsets) {
        self.init(frame: .zero)
        self.padding = padding
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += padding.left + padding.right
        size.height += padding.top + padding.bottom
        return size
    }
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insets = self.padding
        var rect = super.textRect(forBounds: bounds.inset(by: insets), limitedToNumberOfLines: numberOfLines)
        rect.origin.x -= insets.left
        rect.origin.y -= insets.top
        rect.size.width += (insets.left + insets.right)
        rect.size.height += (insets.top + insets.bottom)
        return rect
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let contentSize = super.sizeThatFits(size)
        return CGSize(
            width: contentSize.width + padding.left + padding.right,
            height: contentSize.height + padding.top + padding.bottom
        )
    }
}
