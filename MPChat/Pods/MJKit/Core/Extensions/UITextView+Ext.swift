//
//  UITextView+Ext.swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

// MARK: ===== UITextView =====
public extension UITextView {
    // MARK: 滑动到顶部
    /// 滑动到顶部
    func scrollToTop() {
        let range = NSRange(location: 0, length: 1)
        self.scrollRangeToVisible(range)
    }
    
    // MARK: 滑动到底部
    /// 滑动到底部
    func scrollToBottom() {
        let range = NSRange(location: (self.text as NSString).length - 1, length: 1)
        self.scrollRangeToVisible(range)
    }
    
    // MARK: 清空文字
    /// 清空文字
    func clearText() {
        self.text = ""
        self.attributedText = NSAttributedString(string: "")
    }
    
    // MARK: 插入图片
    /// 插入图片
    func insertPicture(image: UIImage,
                       yOffset: CGFloat = -4) {
        let mutableStr = NSMutableAttributedString(attributedString: self.attributedText)
        
        // 创建图片附件
        let imgAttachment = NSTextAttachment(data: nil, ofType: nil)
        imgAttachment.image = image
        imgAttachment.bounds = CGRect(x: 0, y: yOffset, width: image.size.width,
                                      height: image.size.height)
        
        let imgAttachmentString: NSAttributedString = NSAttributedString(attachment: imgAttachment)
        
        // 获得目前光标的位置
        let selectedRange = self.selectedRange
        // 插入图片
        mutableStr.insert(imgAttachmentString, at: selectedRange.location)
        
        let font: UIFont = self.font ?? UIFont.systemFont(ofSize: 16)
        // 设置可变文本的字体属性
        mutableStr.addAttribute(NSAttributedString.Key.font, value: font,
                                range: NSMakeRange(0, mutableStr.length))
        // 再次记住新的光标的位置
        let newSelectedRange = NSMakeRange(selectedRange.location + 1, 0)
        
        // 重新给文本赋值
        self.attributedText = mutableStr
        // 恢复光标的位置（上面一句代码执行之后，光标会移到最后面）
        self.selectedRange = newSelectedRange
        // 移动滚动条（确保光标在可视区域内）
        self.scrollRangeToVisible(newSelectedRange)
    }
    
    // MARK: 插入文字
    /// 插入文字
    func insertString(_ text: String) {
        let mutableStr = NSMutableAttributedString(attributedString: self.attributedText)
        // 获得目前光标的位置
        let selectedRange = self.selectedRange
        // 插入文字
        let attStr = NSAttributedString(string: text)
        mutableStr.insert(attStr, at: selectedRange.location)
        
        let font: UIFont = self.font ?? UIFont.systemFont(ofSize: 16)
        
        // 设置可变文本的字体属性
        mutableStr.addAttribute(NSAttributedString.Key.font, value: font,
                                range: NSMakeRange(0, mutableStr.length))
        // 再次记住新的光标的位置
        let newSelectedRange = NSMakeRange(selectedRange.location + attStr.length, 0)
        
        // 重新给文本赋值
        self.attributedText = mutableStr
        // 恢复光标的位置（上面一句代码执行之后，光标会移到最后面）
        self.selectedRange = newSelectedRange
    }
    
    /// 设置 UITextView 的内边距
    func setTextInsets(top: CGFloat,
                       left: CGFloat,
                       bottom: CGFloat,
                       right: CGFloat) {
        let textContainerInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        self.textContainerInset = textContainerInset
    }
}
