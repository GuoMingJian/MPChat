//
//  UITextField+Ext.swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

// MARK: ===== UITextField =====
public extension UITextField {
    // MARK: 设置placeholder颜色
    /// 设置placeholder颜色
    func setPlaceholder(color: UIColor) {
        if let subStr = self.placeholder, let font = self.font {
            let range: NSRange = (subStr as NSString).range(of: subStr)
            self.setPlaceholder(range: range, color: color, font: font)
        }
    }
    
    // MARK: 设置placeholder颜色、字体
    /// 设置placeholder颜色、字体
    func setPlaceholder(color: UIColor,
                        fontSize: CGFloat) {
        if let subStr = self.placeholder, let pointSize = self.font?.pointSize {
            let range: NSRange = (subStr as NSString).range(of: subStr)
            
            let tempSize = (fontSize < 5) ? pointSize : fontSize
            let font = UIFont.systemFont(ofSize: tempSize)
            
            self.setPlaceholder(range: range, color: color, font: font)
        }
    }
    
    // MARK: 设置placeholder部分字符串的颜色、字体
    /// 设置placeholder部分字符串的颜色、字体
    func setPlaceholder(subStr: String,
                        color: UIColor,
                        fontSize: CGFloat = 1) {
        if let placeholder = self.placeholder, let pointSize = self.font?.pointSize {
            let range: NSRange = (placeholder as NSString).range(of: subStr)
            let tempSize = (fontSize < 5) ? pointSize : fontSize
            let font = UIFont.systemFont(ofSize: tempSize)
            
            self.setPlaceholder(range: range, color: color, font: font)
        }
    }
    
    /// 设置placeholder部分字符串的颜色、字体
    func setPlaceholder(range: NSRange,
                        color: UIColor,
                        font: UIFont) {
        let placeholderLength = self.placeholder?.count ?? 0
        if range.location != NSNotFound, range.location < placeholderLength, (range.location + range.length <= placeholderLength) {
            let attStr = NSMutableAttributedString()
            if let oldAttStr = self.attributedPlaceholder {
                // 保留之前的attributedPlaceholder
                attStr.append(oldAttStr)
            }
            let att = [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : color]
            attStr.setAttributes(att, range: range)
            self.attributedPlaceholder = attStr
        }
    }
    
    // MARK: 设置字符间距
    /// 设置字符间距
    func setTextKern(_ spac: CGFloat) {
        if let text = self.text, let font = self.font {
            let att: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.kern: NSNumber(value: spac)]
            self.attributedText = NSAttributedString(string: text, attributes: att)
        }
    }
    
    // MARK: 新增AccessoryView
    /// 新增AccessoryView
    func addToolbarInputAccessoryView(barButtonItems: [UIBarButtonItem],
                                      textColor: UIColor? = nil,
                                      toolbarHeight: CGFloat = 44,
                                      backgroundColor: UIColor = .lightText) {
        let toolbar = UIToolbar()
        
        toolbar.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: toolbarHeight)
        toolbar.items = barButtonItems
        toolbar.isTranslucent = false
        toolbar.barTintColor = backgroundColor
        if let aTextColor = textColor {
            toolbar.tintColor = aTextColor
        }
        
        self.inputAccessoryView = toolbar
    }
    
    // MARK: 修改删除按钮颜色
    /// 修改删除按钮颜色
    func changeClearButtonColor(_ color: UIColor) {
        if let clearButton = self.value(forKey: "clearButton") as? UIButton {
            clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            clearButton.tintColor = color
        }
    }
    
    // MARK: 修改placeholder颜色
    /// 修改placeholder颜色
    func changePlaceholder(placeholder: String? = nil,
                           color: UIColor) {
        var newPlaceholder: String = self.placeholder ?? ""
        if let placeholder = placeholder {
            newPlaceholder = placeholder
        }
        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: color]
        let attributedPlaceholder = NSAttributedString(string: newPlaceholder, attributes: placeholderAttributes)
        self.attributedPlaceholder = attributedPlaceholder
    }
}
