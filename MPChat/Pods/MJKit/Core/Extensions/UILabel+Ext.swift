//
//  UILabel+Ext.swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

// MARK: ===== UILabel =====
public extension UILabel {
    // MARK: 添加删除线
    /// 添加删除线
    func addDeleteLine(deleteString: String,
                       deleteFont: UIFont? = nil) {
        let text = self.text ?? ""
        let font: UIFont = self.font ?? UIFont.systemFont(ofSize: 16)
        var delFont: UIFont = font
        if let tempFont = deleteFont {
            delFont = tempFont
        }
        let color: UIColor = self.textColor ?? UIColor.lightGray
        //
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: font])
        let rang: NSRange = text.range(of: deleteString)
        
        attributeString.addAttributes([NSAttributedString.Key.baselineOffset : 0,
                                       NSAttributedString.Key.strikethroughStyle: 1.5,
                                       NSAttributedString.Key.foregroundColor: color,
                                       NSAttributedString.Key.font: delFont], range: rang)
        self.attributedText = attributeString
    }
    
    // MARK: Label 文字渐变色
    /// Label 文字渐变色
    func setGradientText(text: String? = nil,
                         font: UIFont? = nil,
                         colors: [UIColor],
                         gradientType: GradientPointType = .leftToRight) {
        var startPoint: CGPoint = CGPoint(x: 0.5, y: 0)
        var endPoint: CGPoint = CGPoint(x: 0.5, y: 1)
        let result = getGradientPoints(type: gradientType)
        startPoint = result.startPoint
        endPoint = result.endPoint
        //
        var newText = self.text ?? ""
        if let text = text {
            newText = text
        }
        //
        setGradientText(text: newText, font: font, colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
    
    /// Label 文字渐变色
    func setGradientText(text: String,
                         font: UIFont? = nil,
                         colors: [UIColor],
                         startPoint: CGPoint = CGPoint(x: 0, y: 0.5),
                         endPoint: CGPoint = CGPoint(x: 1, y: 0.5)) {
        var newFont: UIFont = self.font
        if let font = font {
            newFont = font
        }
        // 创建渐变图层
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        // 绘制渐变色
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        // 确保上下文在结束时被关闭
        defer { UIGraphicsEndImageContext() }
        // 获取当前图形上下文
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        gradientLayer.render(in: context)
        // 获取渐变图像
        guard let gradientImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return
        }
        
        // 将渐变色应用到文字
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .foregroundColor: UIColor(patternImage: gradientImage),
                .font: newFont
            ]
        )
        self.attributedText = attributedString
    }
    
    // MARK: 判断文字是否超出显示
    /// 判断文字是否超出显示
    func isOverlength() -> Bool {
        guard let text = self.text, text.count > 0 else {
            return false
        }
        
        self.layoutIfNeeded()
        self.setNeedsLayout()
        
        let textSize = CGSize(width: self.frame.size.width, height: .greatestFiniteMagnitude)
        let boundingRect = (text as NSString).boundingRect(with: textSize,
                                                           options: .usesLineFragmentOrigin,
                                                           attributes: [NSAttributedString.Key.font: self.font as Any],
                                                           context: nil)
        return boundingRect.size.height > self.bounds.size.height + 1
    }
    
    // MARK: 当字符串过长，中间显示'...'，末尾保留x位
    /// 当字符串过长，中间显示'...'，末尾保留x位
    func getMaxString(_ lastStringCount: Int = 5) -> String {
        var result: String = self.text ?? ""
        let isOver = self.isOverlength()
        if isOver {
            //
            let text: String = self.text ?? ""
            let lastStringCount: Int = lastStringCount
            let midleStr: String = "..."
            var finallyStr: String = ""
            //
            if text.count > lastStringCount + 1 {
                finallyStr = text.subString(startIndex: text.count - lastStringCount, count: lastStringCount)
            }
            //
            var prefixStr = ""
            for index in 1..<text.count {
                prefixStr = text.subString(startIndex: 0, count: index)
                result = prefixStr + midleStr + finallyStr
                self.text = result
                let isOver = self.isOverlength()
                if isOver {
                    prefixStr = prefixStr.subString(startIndex: 0, count: prefixStr.count - 1)
                    result = prefixStr + midleStr + finallyStr
                    // print("文本超出，最大显示字符个数数(\(result.count))")
                    break
                }
            }
        }
        //
        return result
    }
    
    /// 植入图标
    func embedIcon(_ iconImage: UIImage?,
                   atPosition position: Int,
                   withSpacing spacing: CGFloat = 8) {
        guard let iconImage = iconImage,
              let labelText = self.text,
              !labelText.isEmpty else { return }
        
        let textAttachment = NSTextAttachment()
        textAttachment.image = iconImage
        
        let labelFont = self.font ?? UIFont.systemFont(ofSize: 17)
        let iconHeight = labelFont.lineHeight
        let iconWidth = iconImage.size.width * (iconHeight / iconImage.size.height)
        
        // 优化图标垂直对齐
        let yOffset = (labelFont.capHeight - iconHeight) * 0.5
        textAttachment.bounds = CGRect(x: 0, y: yOffset, width: iconWidth, height: iconHeight)
        
        let iconAttributedString = NSAttributedString(attachment: textAttachment)
        let spacingAttributedString = NSAttributedString(string: " ")
        
        let mutableText = NSMutableAttributedString(string: labelText)
        mutableText.addAttribute(.font, value: labelFont, range: NSRange(location: 0, length: labelText.count))
        
        let insertionIndex = max(0, min(position, labelText.count))
        
        if insertionIndex < labelText.count {
            mutableText.insert(spacingAttributedString, at: insertionIndex)
            mutableText.insert(iconAttributedString, at: insertionIndex)
        } else {
            mutableText.append(spacingAttributedString)
            mutableText.append(iconAttributedString)
        }
        
        self.attributedText = mutableText
    }
}

public extension UILabel {
    // MARK: 设置富文本（支持精确匹配和模糊匹配）
    /// 设置富文本
    /// - Parameters:
    ///   - subStrList: 要匹配的子字符串列表
    ///   - color: 高亮颜色
    ///   - font: 高亮字体
    ///   - isSetOne: 是否只设置第一个匹配项
    ///   - matchOption: 匹配选项（精确匹配 / 大小写不敏感）
    func setAttributes(subStrList: Array<String>,
                       color: UIColor? = nil,
                       font: UIFont? = nil,
                       isSetOne: Bool = false,
                       matchOption: MatchOption = .caseInsensitive) {
        
        let text: String = self.text ?? ""
        var newColor: UIColor = self.textColor
        if let color = color {
            newColor = color
        }
        var newFont: UIFont = self.font
        if let font = font {
            newFont = font
        }
        
        let attM: NSMutableAttributedString = NSMutableAttributedString(string: text)
        
        for searchStr in subStrList {
            let ranges = findRanges(for: searchStr, in: text, option: matchOption, isSetOne: isSetOne)
            
            let att = [NSAttributedString.Key.font : newFont,
                       NSAttributedString.Key.foregroundColor : newColor]
            for range in ranges {
                attM.addAttributes(att, range: range)
            }
        }
        
        self.attributedText = attM
    }
    
    /// 匹配选项
    enum MatchOption {
        case exact           // 精确匹配
        case caseInsensitive // 大小写不敏感
    }
    
    /// 查找匹配范围
    private func findRanges(for searchStr: String,
                            in text: String,
                            option: MatchOption,
                            isSetOne: Bool) -> [NSRange] {
        var rangeList: [NSRange] = []
        var supStr = text
        var index: Int = 0
        
        let compareOptions: NSString.CompareOptions = (option == .caseInsensitive) ? .caseInsensitive : []
        
        while supStr.count > 0 {
            let range = (supStr as NSString).range(of: searchStr, options: compareOptions)
            
            if range.location != NSNotFound {
                if isSetOne {
                    supStr = ""
                } else {
                    supStr = (supStr as NSString).substring(from: range.location + range.length)
                }
                
                let adjustedRange = NSRange(location: range.location + index,
                                            length: range.length)
                index = adjustedRange.location + adjustedRange.length
                rangeList.append(adjustedRange)
            } else {
                supStr = ""
            }
        }
        
        return rangeList
    }
}
