//
//  UIButton+Ext.swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

public extension UIButton {
    // MARK: 设置按钮文字渐变颜色
    /// 设置按钮文字渐变颜色
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
        var newText = self.titleLabel?.text ?? ""
        if let text = text {
            newText = text
        }
        //
        setGradientText(text: newText, font: font, colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
    
    func setGradientText(text: String,
                         font: UIFont? = nil,
                         colors: [UIColor],
                         startPoint: CGPoint = CGPoint(x: 0, y: 0.5),
                         endPoint: CGPoint = CGPoint(x: 1, y: 0.5)) {
        var newFont: UIFont = self.titleLabel?.font ?? UIFont.systemFont(ofSize: 16)
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
        self.setAttributedTitle(attributedString, for: .normal)
    }
    
    // MARK: 按钮添加下划线
    /// 按钮添加下划线 (margin: 下划线与文字间距)
    func addBottomLine(margin: CGFloat = 5,
                       isThick: Bool = false) {
        let text: String = self.titleLabel?.text ?? ""
        let str = NSMutableAttributedString(string: text)
        let strRange = NSRange(location: 0, length: str.length)
        
        // 字体颜色和字体
        let lineColor: UIColor = self.titleLabel?.textColor ?? .black
        let font: UIFont = self.titleLabel?.font ?? UIFont.systemFont(ofSize: 16)
        
        // 下划线样式
        var underlineStyle: NSUnderlineStyle = .single
        if isThick {
            underlineStyle = .thick
        }
        let number = NSNumber(value: underlineStyle.rawValue)
        
        // 添加下划线样式和字体颜色
        str.addAttributes([NSAttributedString.Key.foregroundColor: lineColor,
                           NSAttributedString.Key.font: font,
                           NSAttributedString.Key.underlineStyle: number,
                           NSAttributedString.Key.baselineOffset: margin], range: strRange)
        // 设置为按钮的 attributedTitle
        self.setAttributedTitle(str, for: .normal)
    }
    
    // MARK: 设置按钮图标与文字之间的间距
    /// 设置按钮图标与文字之间的间距
    /// - Parameter spacing: 图标与文字之间的间距，默认为10
    func setImageTextSpacing(spacing: CGFloat = 10) {
        if #available(iOS 15.0, *) {
            // 创建按钮配置
            var configuration = self.configuration ?? UIButton.Configuration.plain()
            // 设置图标与文字的间距
            configuration.imagePadding = spacing
            // 应用配置
            self.configuration = configuration
        } else {
            // 设置图标与文字的边距
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: 0)
        }
    }
}
