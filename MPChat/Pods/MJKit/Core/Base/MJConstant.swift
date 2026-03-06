//
//  MJConstant.swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

// MARK: - ========== 常量定义 ==========
public struct MJ {
    /// 状态栏高度
    public static var kStatusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let statusBarManager = windowScene.statusBarManager else {
                return 0.0
            }
            return statusBarManager.statusBarFrame.size.height
        } else {
            return UIApplication.shared.statusBarFrame.size.height
        }
    }
    
    /// 导航栏Bar高度
    public static var kNavigationBarHeight: CGFloat {
        return UINavigationController().navigationBar.frame.height
    }
    
    /// 导航高度
    public static var kNavigationHeight: CGFloat {
        return kStatusBarHeight + kNavigationBarHeight
    }
    
    /// TabBar高度
    public static var kTabBarHeight: CGFloat {
        return UITabBarController().tabBar.frame.height
    }
    
    /// 屏幕宽
    public static var kScreenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    /// 屏幕高
    public static var kScreenHeight: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    /// 顶部安全间距
    public static var kSafeAreaTopHeight: CGFloat {
        guard #available(iOS 11.0, *) else { return 0.0 }
        if #available(iOS 15.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            return windowScene?.windows.first?.safeAreaInsets.top ?? 0.0
        } else {
            return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0.0
        }
    }
    
    /// 底部安全间距
    public static var kSafeAreaBottomHeight: CGFloat {
        guard #available(iOS 11.0, *) else { return 0.0 }
        if #available(iOS 15.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            return windowScene?.windows.first?.safeAreaInsets.bottom ?? 0.0
        } else {
            return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        }
    }
    
    /// 判断当前设备是否是iPhone
    public static var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    // 判断当前设备是否是iPad
    public static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

// MARK: - 宽高自适应
public extension MJ {
    // 按 iphoneX/XS/11Pro/12min: 375宽自适应比例
    static func adjustsIphoneXWidth(_ value: CGFloat) -> CGFloat {
        return kScreenWidth * (value / 375.0)
    }
    
    // 按 iphoneX/XS/11Pro/12min: 812高自适应比例
    static func adjustsIphoneXHeight(_ value: CGFloat) -> CGFloat {
        return kScreenHeight * (value / 812.0)
    }
}

// MARK: - dateFormat
public extension MJ {
    /// "yyyy-MM-dd"
    static let yyyyMMdd = "yyyy-MM-dd"
    /// "yyyy-MM-dd HH:mm"
    static let yyyyMMddHHmm = "yyyy-MM-dd HH:mm"
    /// "yyyy-MM-dd HH:mm:ss"
    static let yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss"
    /// "yyyy-MM-dd HH:mm:ss.SSS"
    static let yyyyMMddHHmmssSSS = "yyyy-MM-dd HH:mm:ss.SSS"
    /// "HH:mm"
    static let HHmm = "HH:mm"
    /// "HH:mm:ss"
    static let HHmmss = "HH:mm:ss"
    /// "HH:mm aa"
    static let HHmmaa = "HH:mm aa"
    /// "yyyyMMdd"
    static let yyyyMMdd_unsigned = "yyyyMMdd"
    /// "yyyyMMddHHmmss"
    static let yyyyMMddHHmmss_unsigned = "yyyyMMddHHmmss"
    /// "MMM dd, yyyy"
    static let MMMddyyyy = "MMM dd, yyyy"
    /// "MMM dd"
    static let MMMdd = "MMM dd"
    /*
     G: 公元时代，例如AD公元
     yy: 年的后2位
     yyyy: 完整年
     MM: 月，显示为1-12
     MMM: 月，显示为英文月份简写,如 Jan
     MMMM: 月，显示为英文月份全称，如 Janualy
     dd: 日，2位数表示，如02
     d: 日，1-2位显示，如 2
     EEE: 简写星期几，如Sun
     EEEE: 全写星期几，如Sunday
     aa: 上下午，AM/PM
     H: 时，24小时制，0-23
     K：时，12小时制，0-11
     m: 分，1-2位
     mm: 分，2位
     s: 秒，1-2位
     ss: 秒，2位
     S: 毫秒
     */
}

// MARK: - 常量类型转字符串
// MARK: Int
public extension Int {
    /// Int -> String
    func toString() -> String {
        return String(self)
    }
}

// MARK: - Float
public extension Float {
    /// Float -> String
    func toString() -> String {
        return String(self)
    }
}

// MARK: - Double
public extension Double {
    /// Double -> String
    func toString(decimal: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimal
        formatter.maximumFractionDigits = decimal
        
        guard let formattedString = formatter.string(from: NSNumber(value: self)) else {
            // 如果格式化失败，返回原始字符串
            return "\(self)"
        }
        return formattedString
    }
    
    /// 转换为大小单位：UInt64 -> "bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"
    func covertToUnitString() -> String {
        var convertedValue: Double = Double(self)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB", "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        // 总宽度为 4 个字符。如果数字小于 4 个字符，前面会用空格填充
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
}

// MARK: - Bool
public extension Bool {
    /// Bool 转 String (True/False)
    func toString() -> String {
        return self ? "True" : "False"
    }
    
    /// Bool 转 Int (1/0)
    func toInt() -> Int {
        return self ? 1 : 0
    }
}

public extension String {
    func toBool() -> Bool {
        return self == "True"
    }
}

// MARK: - CGFloat
public extension CGFloat {
    /// Absolute of CGFloat value.
    var abs: CGFloat {
        return Swift.abs(self)
    }
    
    /// Ceil of CGFloat value.
    var ceil: CGFloat {
        return Foundation.ceil(self)
    }
    
    /// Floor of CGFloat value.
    var floor: CGFloat {
        return Foundation.floor(self)
    }
    
    /// Int.
    var int: Int {
        return Int(self)
    }
    
    /// Float.
    var float: Float {
        return Float(self)
    }
    
    /// Double.
    var double: Double {
        return Double(self)
    }
    
    /// 度转弧
    var degreesToRadians: CGFloat {
        return .pi * self / 180.0
    }
    
    /// 弧转度
    var radiansToDegrees: CGFloat {
        return self * 180 / CGFloat.pi
    }
}

// MARK: - Encodable
public extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap {
            $0 as? [String: Any]
        }
    }
    
    var json: String {
        var json = ""
        if let dict: NSDictionary = self.dictionary as? NSDictionary {
            json = String.dictionaryToJson(dictionary: dict)
        }
        return json
    }
}

// MARK: - UserDefaults
public extension UserDefaults {
    /// 设置 UserDefaults key-value
    static func set(value: String,
                    key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    /// 获取 UserDefaults key-value
    static func get(key: String) -> String {
        if let value: String = UserDefaults.standard.object(forKey: key) as? String {
            return value
        } else {
            UserDefaults.set(value: "", key: key)
            return ""
        }
    }
    
    /// 移除 key
    static func removeKey(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
}

// MARK: - NSRange
public extension NSRange {
    // MARK: NSRange 转 Range
    /// NSRange 转 Range
    func toRange(string: String) -> Range<String.Index>? {
        guard
            let from16 = string.utf16.index(string.utf16.startIndex, offsetBy: self.location, limitedBy: string.utf16.endIndex),
            let to16 = string.utf16.index(from16, offsetBy: self.length, limitedBy: string.utf16.endIndex),
            let from = String.Index(from16, within: string),
            let to = String.Index(to16, within: string)
        else { return nil }
        return from ..< to
    }
}

// MARK: - Range
public extension Range where Bound == String.Index {
    // MARK: Range 转 NSRange
    /// Range 转 NSRange
    func toNSRange(in string: String) -> NSRange {
        let utf16Start = string.distance(from: string.startIndex, to: self.lowerBound)
        let utf16End = string.distance(from: string.startIndex, to: self.upperBound)
        return NSRange(location: utf16Start, length: utf16End - utf16Start)
    }
}

// MARK: - ===== Array =====
public extension Array where Element: Equatable {
    mutating func remove(_ item: Element) {
        if let idx = firstIndex(of: item) {
            remove(at: idx)
        }
    }
    
    mutating func remove(_ items: [Element]) {
        for item in items {
            remove(item)
        }
    }
    
    mutating func remove(at indexes: [Int]) {
        for index in indexes.sorted(by: >) {
            remove(at: index)
        }
    }
    
    func safeObject(at index: Array.Index) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}

// MARK: - 自定义打印
public extension MJ {
    // xcode 屏蔽奇怪打印信息：OS_ACTIVITY_MODE -> disable
    
    /// 自定义打印
    /// - Parameter msg: 打印的内容
    /// - Parameter file: 文件路径
    /// - Parameter line: 打印内容所在的 行
    /// - Parameter column: 打印内容所在的 列
    /// - Parameter fn: 打印内容的函数名
    static func printInfo(_ msg: Any...,
                          file: NSString = #file,
                          line: Int = #line,
                          column: Int = #column,
                          fn: String = #function) {
#if DEBUG
        var msgStr = ""
        for element in msg {
            msgStr += "\(element)\n"
        }
        let currentDate = Date.currentDateString(dateFormat: MJ.yyyyMMddHHmmss)
        var logStr: String = ""
        logStr.append("---begin---------------🚀----------------\n")
        logStr.append("当前时间：\(currentDate)\n")
        logStr.append("当前文件完整的路径是：\(file)\n")
        logStr.append("当前文件是：\(file.lastPathComponent)\n")
        logStr.append("第 \(line) 行\n")
        //logStr.append("第 \(column) 列\n")
        logStr.append("函数名：\(fn)\n")
        logStr.append("=== 打印内容如下 ===\n")
        logStr.append("\(msgStr)")
        logStr.append("---end-----------------😊----------------")
        print(logStr)
#endif
    }
}

// MARK: - Notification
public extension Notification.Name {
    struct MJ {
        /// 登入
        static let kLoginSuccessNotification = Notification.Name(rawValue: "kLoginSuccessNotification")
        /// 登出
        static let kLogoutNotification = Notification.Name(rawValue: "kLogoutNotification")
    }
}
