//
//  UIFont+Ext.swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

/*
 Info.plist
 <key>UIAppFonts</key>
 <array>
 <string>DINAlternate-Bold.ttf</string>
 <string>SFProText-Regular.ttf</string>
 <string>SFProText-Medium.ttf</string>
 <string>SFProText-Semibold.ttf</string>
 <string>SFProText-Bold.ttf</string>
 </array>
 */

import UIKit

public extension UIFont {
    // MARK: PingFang (系统自带)
    /// PingFangSC-Light
    /// - Parameter fontSize: 字体大小
    /// - Returns: UIFont
    static func PFLight(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Light", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// PingFangSC-Regular
    /// - Parameter fontSize: 字体大小
    /// - Returns: UIFont
    static func PFRegular(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// PingFangSC-Medium
    /// - Parameter fontSize: 字体大小
    /// - Returns: UIFont
    static func PFMedium(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Medium", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// PingFangSC-Semibold
    /// - Parameter fontSize: 字体大小
    /// - Returns: UIFont
    static func PFSemibold(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Semibold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// PingFangSC-Ultralight
    /// - Parameter fontSize: 字体大小
    /// - Returns: UIFont
    static func PFUltralight(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Ultralight", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// PingFangSC-Thin
    /// - Parameter fontSize: 字体大小
    /// - Returns: UIFont
    static func PFThin(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Thin", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
}

public extension UIFont {
    // MARK: SFProText
    /// SFProText-Regular
    static func SFP_Regular(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// SFProText-Medium
    static func SFP_Medium(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Medium", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// SFProText-Semibold
    static func SFP_Semibold(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Semibold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    /// SFProText-Bold
    static func SFP_Bold(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
}

// MARK: - DINAlternate
public extension UIFont {
    /// DINAlternate-Bold
    static func DIN_Bold(fontSize: CGFloat) -> UIFont {
        return UIFont(name: "DINAlternate-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
}

public extension UIFont {
    static let systemFontRegular10 = systemFont(ofSize: 10, weight: .regular)
    static let systemFontRegular11 = systemFont(ofSize: 11, weight: .regular)
    static let systemFontRegular12 = systemFont(ofSize: 12, weight: .regular)
}

public extension UIFont {
    struct System {
        public static let regular10 = generate(10, .regular)
        public static let regular11 = generate(11, .regular)
        public static let regular12 = generate(12, .regular)
        public static let regular13 = generate(13, .regular)
        public static let regular14 = generate(14, .regular)
        public static let regular15 = generate(15, .regular)
        public static let regular16 = generate(16, .regular)
        public static let regular17 = generate(17, .regular)
        public static let regular18 = generate(18, .regular)
        public static let regular19 = generate(19, .regular)
        public static let regular20 = generate(20, .regular)
        public static let regular21 = generate(21, .regular)
        public static let regular22 = generate(22, .regular)
        public static let regular23 = generate(23, .regular)
        public static let regular24 = generate(24, .regular)
        public static let regular25 = generate(25, .regular)
        //
        public static let semibold10 = generate(10, .semibold)
        public static let semibold11 = generate(11, .semibold)
        public static let semibold12 = generate(12, .semibold)
        public static let semibold13 = generate(13, .semibold)
        public static let semibold14 = generate(14, .semibold)
        public static let semibold15 = generate(15, .semibold)
        public static let semibold16 = generate(16, .semibold)
        public static let semibold17 = generate(17, .semibold)
        public static let semibold18 = generate(18, .semibold)
        public static let semibold19 = generate(19, .semibold)
        public static let semibold20 = generate(20, .semibold)
        public static let semibold21 = generate(21, .semibold)
        public static let semibold22 = generate(22, .semibold)
        public static let semibold23 = generate(23, .semibold)
        public static let semibold24 = generate(24, .semibold)
        public static let semibold25 = generate(25, .semibold)
        public static let semibold26 = generate(26, .semibold)
        public static let semibold27 = generate(27, .semibold)
        public static let semibold28 = generate(28, .semibold)
        public static let semibold29 = generate(29, .semibold)
        public static let semibold30 = generate(30, .semibold)
        //
        public static let bold10 = generate(10, .bold)
        public static let bold11 = generate(11, .bold)
        public static let bold12 = generate(12, .bold)
        public static let bold13 = generate(13, .bold)
        public static let bold14 = generate(14, .bold)
        public static let bold15 = generate(15, .bold)
        public static let bold16 = generate(16, .bold)
        public static let bold17 = generate(17, .bold)
        public static let bold18 = generate(18, .bold)
        public static let bold19 = generate(19, .bold)
        public static let bold20 = generate(20, .bold)
        public static let bold21 = generate(21, .bold)
        public static let bold22 = generate(22, .bold)
        public static let bold23 = generate(23, .bold)
        public static let bold24 = generate(24, .bold)
        public static let bold25 = generate(25, .bold)
        public static let bold26 = generate(26, .bold)
        public static let bold27 = generate(27, .bold)
        public static let bold28 = generate(28, .bold)
        public static let bold29 = generate(29, .bold)
        public static let bold30 = generate(30, .bold)
        
        private static func generate(_ size: CGFloat, _ weight: Weight) -> UIFont {
            .systemFont(ofSize: size, weight: weight)
        }
    }
}
