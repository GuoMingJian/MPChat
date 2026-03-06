//
//  UIColor+Ext.swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

public extension UIColor {
    /// 当前颜色的16进制字符串
    var hexString: String {
        if let components = self.cgColor.components, components.count >= 3 {
            let r = components[0]
            let g = components[1]
            let b = components[2]
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }
        return ""
    }
    
    // MARK: 16进制字符串 -> UIColor
    /// 16进制字符串 -> UIColor
    static func hexColor(color: String,
                         alpha: CGFloat = 1) -> UIColor {
        var colorString = color.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if colorString.count < 6 {
            return UIColor.clear
        }
        
        if colorString.hasPrefix("0x") {
            colorString = String(colorString.dropFirst(2))
        }
        
        if colorString.hasPrefix("#") {
            colorString = String(colorString.dropFirst(1))
        }
        
        guard colorString.count == 6 else {
            return UIColor.clear
        }
        
        var rang = NSRange()
        rang.location = 0
        rang.length = 2
        
        let rString = (colorString as NSString).substring(with: rang)
        rang.location = 2
        let gString = (colorString as NSString).substring(with: rang)
        rang.location = 4
        let bString = (colorString as NSString).substring(with: rang)
        
        var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0
        
        Scanner(string: rString).scanHexInt64(&r)
        Scanner(string: gString).scanHexInt64(&g)
        Scanner(string: bString).scanHexInt64(&b)
        
        let color = UIColor(CGFloat(r), CGFloat(g), CGFloat(b), alpha)
        return color
    }
    
    // MARK: 随机颜色
    /// 随机颜色
    static func randomColor() -> UIColor {
        let color = UIColor(CGFloat(arc4random_uniform(256)) / 255.0,
                            CGFloat(arc4random_uniform(256)) / 255.0,
                            CGFloat(arc4random_uniform(256)) / 255.0)
        return color
    }
    
    // MARK: 黑色
    /// 黑色
    static func black(alpha: CGFloat = 1) -> UIColor {
        return UIColor.hexColor(color: "#000000", alpha: alpha)
    }
    
    // MARK: 白色
    /// 白色
    static func white(alpha: CGFloat = 1) -> UIColor {
        return UIColor.hexColor(color: "#FFFFFF", alpha: alpha)
    }
}

public extension String {
    /// "#FFFFFF" -> UIColor
    var toUIColor: UIColor {
        return UIColor.hexColor(color: self)
    }
}

// MARK: - ===== 便利初始化 =====
public extension UIColor {
    /// 使用 RGBA 生成颜色
    convenience init(_ r: CGFloat,
                     _ g: CGFloat,
                     _ b: CGFloat,
                     _ alpha: CGFloat = 1.0) {
        let red = r / 255.0
        let green = g / 255.0
        let blue = b / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// 适配深色模式
    convenience init(light: UIColor,
                     dark: UIColor) {
        if #available(iOS 13.0, tvOS 13.0, *) {
            self.init(dynamicProvider: { $0.userInterfaceStyle == .dark ? dark : light })
        } else {
            self.init(cgColor: light.cgColor)
        }
    }
}
