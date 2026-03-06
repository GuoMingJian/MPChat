//
//  UIView+Ext(RedDot).swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

// MARK: - ===== UIView (未读消息，红点) =====
public let K_RED_DOT_TAG: Int = 1991
public extension UIView {
    // MARK: 未读消息（小红点）
    /// 未读消息（小红点）
    func showRedDot(dotColor: UIColor = .red,
                    dotWidth: CGFloat = 10,
                    xOffset: CGFloat = -2,
                    yOffset: CGFloat = 3) {
        hiddenRedDot()
        self.layoutIfNeeded()
        self.layer.masksToBounds = false
        //
        let dotView = UIView()
        dotView.layer.cornerRadius = CGFloat(dotWidth / 2.0)
        dotView.layer.masksToBounds = true
        dotView.backgroundColor = dotColor
        dotView.tag = K_RED_DOT_TAG
        self.addSubview(dotView)
        //
        let superWidth = self.frame.size.width
        let x: CGFloat = superWidth - (dotWidth / 2 - xOffset)
        let y: CGFloat = -(dotWidth / 2 - yOffset)
        let rect: CGRect = CGRect(x: x, y: y, width: dotWidth, height: dotWidth)
        dotView.frame = rect
    }
    
    // MARK: 隐藏小红点
    /// 隐藏小红点
    func hiddenRedDot() {
        if let dotView: UIView = self.viewWithTag(K_RED_DOT_TAG) {
            dotView.removeFromSuperview()
        }
    }
    
    // MARK: 显示未读消息数
    /// 显示未读消息数，unreadCount <= 0 时，隐藏
    func showUnreadMessage(unreadCount: Int,
                           txtFont: UIFont = UIFont.boldSystemFont(ofSize: 10),
                           xOffset: CGFloat = 1,
                           yOffset: CGFloat = 1) {
        hiddenUnreadMessage()
        if unreadCount <= 0 {
            return
        }
        var dotWidth: CGFloat = 16
        let dotHeight: CGFloat = 16
        let cornerRadius: CGFloat = dotWidth / 2.0
        if unreadCount > 9, unreadCount < 99 {
            dotWidth = 22
        }
        if unreadCount >= 99 {
            dotWidth = 30
        }
        self.layoutIfNeeded()
        self.layer.masksToBounds = false
        //
        let dotView = UIView()
        dotView.layer.cornerRadius = cornerRadius
        dotView.layer.masksToBounds = true
        dotView.backgroundColor = UIColor.red
        dotView.tag = K_RED_DOT_TAG + 1
        self.addSubview(dotView)
        //
        let superWidth = self.frame.size.width
        let x: CGFloat = superWidth - (dotWidth / 2 - xOffset)
        let y: CGFloat = -(dotHeight / 2 - yOffset)
        let rect: CGRect = CGRect(x: x, y: y, width: dotWidth, height: dotHeight)
        dotView.frame = rect
        //
        let label = UILabel()
        label.text = "\(unreadCount)"
        if unreadCount >= 99 {
            label.text = "99+"
        }
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.white
        label.font = txtFont
        label.textAlignment = .center
        label.frame = dotView.bounds
        dotView.addSubview(label)
    }
    
    // MARK: 隐藏未读消息数
    /// 隐藏未读消息数
    func hiddenUnreadMessage() {
        if let dotView: UIView = self.viewWithTag(K_RED_DOT_TAG + 1) {
            dotView.removeFromSuperview()
        }
    }
}
