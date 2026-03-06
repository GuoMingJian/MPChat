//
//  String+Ext(Common).swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

// MARK: ===== String (获取子字符串) =====
public extension String {
    // MARK: 取字符串前x个
    /// 截取字符串前x个
    static func prefix(input: String,
                       number: Int) -> String {
        if input.count < number {
            return input
        }
        let result = String(input.prefix(number))
        return result
    }
    
    // MARK: 获取字符串某个索引的字符（从前往后,从0开始算的）
    /// 获取字符串某个索引的字符（从前往后,从0开始算的）
    func getCharAdvance(index: Int) -> String {
        assert(index < self.count, "字符串索引越界了！")
        let positionIndex = self.index(self.startIndex, offsetBy: index)
        let char = self[positionIndex]
        return String(char)
    }
    
    // MARK: 获取字符串第一个字符
    /// 获取字符串第一个字符
    func getFirstChar() -> String {
        return getCharAdvance(index: 0)
    }
    
    // MARK: 获取字符串某个索引的字符（从后往前）
    /// 获取字符串某个索引的字符（从后往前）
    func getCharReverse(index: Int) -> String {
        assert(index < self.count, "字符串索引越界了！")
        // 在这里做了索引减1，因为endIndex获取的是 字符串最后一个字符的下一位
        let positionIndex = self.index(self.endIndex, offsetBy: -index - 1)
        let char = self[positionIndex]
        return String(char)
    }
    
    // MARK: 获取字符串最后一个字符
    /// 获取字符串最后一个字符
    func getLastChar() -> String {
        return getCharReverse(index: 0)
    }
    
    // MARK: 获取某一串字符串按索引值 （前闭后开 包含前边不包含后边）
    /// 获取某一串字符串按索引值 （前闭后开 包含前边不包含后边）
    func subString(startIndex: Int,
                   endIndex: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: startIndex)
        let end = self.index(self.startIndex, offsetBy: endIndex)
        return String (self[start ..< end])
    }
    
    // MARK: 获取某一串字符串按数量
    /// 获取某一串字符串按数量
    func subString(startIndex: Int,
                   count: Int) -> String {
        return subString(startIndex: startIndex, endIndex: startIndex + count)
    }
    
    // MARK: 截取字符串从某个索引开始截取 包含当前索引
    /// 截取字符串从某个索引开始截取 包含当前索引
    func subStringFrom(startIndex: Int) -> String {
        return subString(startIndex: startIndex, endIndex: self.count)
    }
    
    // MARK: 截取字符串（从开始截取到想要的索引位置）不包含当前索引
    /// 截取字符串（从开始截取到想要的索引位置）不包含当前索引
    func subStringTo(endIndex: Int) -> String {
        return subString(startIndex: 0, endIndex: endIndex)
    }
    
    // MARK: 获取子字符串的范围NSRange
    /// 获取子字符串的范围NSRange
    func range(of subString: String) -> NSRange {
        let text = self as NSString
        return text.range(of: subString)
    }
}

// MARK: ===== String (APP 信息) =====
public extension String {
    // MARK: app 显示名称 CFBundleDisplayName'
    /// app 显示名称 CFBundleDisplayName'
    static func appDisplayName() -> String {
        let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
        return appName
    }
    
    // MARK: app 项目名称 'CFBundleName'
    /// app 项目名称 'CFBundleName'
    static func appBundleName() -> String {
        let bundleName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        return bundleName
    }
    
    // MARK: app bundle id
    /// app bundle id
    static func appBundleId() -> String {
        if let bundleID = Bundle.main.bundleIdentifier {
            return bundleID
        }
        return ""
    }
    
    // MARK: app 版本号
    /// app 版本号
    static func appVersion() -> String {
        let appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        return appVersion
    }
    
    // MARK: app Build号
    /// app Build号
    static func appBuild() -> String {
        let appBuild: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        return appBuild
    }
    
    // MARK: 设备型号
    /// 设备型号
    static func deviceModel() -> String {
        let dev = UIDevice.current
        let deviceName = dev.name
        return deviceName
    }
    
    // MARK: 设备系统
    /// 设备系统
    static func deviceVersion() -> String {
        let dev = UIDevice.current
        let deviceVersion = "\(dev.systemName) \(dev.systemVersion)"
        return deviceVersion
    }
    
    // MARK: 手机电量
    /// 手机电量
    static func deviceBatteryLevel() -> String {
        let dev = UIDevice.current
        let batteryLevel = dev.batteryLevel.toString()
        return batteryLevel
    }
    
    // MARK: 手机电量
    /// 充电状态
    static func deviceBatteryState() -> String {
        let dev = UIDevice.current
        let state = dev.batteryState
        switch state {
        case .charging:
            return "充电中"
        case .full:
            return "充电已满"
        case .unplugged:
            return "不插电的"
        case .unknown:
            return "未知"
        @unknown default:
            return "未知"
        }
    }
    
    //    static func deviceInfo() {
    //        let dev = UIDevice.current
    //        print("是否支持多任务：\(dev.isMultitaskingSupported ? "是" : "否")")
    //        print("设备名字：\(dev.name)")
    //        print("系统名字：\(dev.systemName)")
    //        print("系统版本：\(dev.systemVersion)")
    //        print("设备 model：\(dev.model)")
    //        print("设备本地化 model：\(dev.localizedModel)")
    //        print("用户界面类型：\(dev.userInterfaceIdiom.rawValue)")
    //        print("设备厂商标识：\(dev.identifierForVendor?.uuidString ?? "无")")
    //        print("设备方向：\(dev.orientation.rawValue)")
    //        print("是否可以生成设备方向通知：\(dev.isGeneratingDeviceOrientationNotifications ? "是" : "否")")
    //        print("设备电量：\(dev.batteryLevel)")
    //        print("电量监测是否启用：\(dev.isBatteryMonitoringEnabled ? "是" : "否")")
    //        print("设备电量状态：\(dev.batteryState.rawValue)")
    //        print("距离感应器是否可以使用：\(dev.isProximityMonitoringEnabled ? "是" : "否")")
    //        print("距离感应器是否打开：\(dev.proximityState ? "是" : "否")")
    //    }
    
    // MARK: Info.plist
    /// Info.plist
    static func appInfoDictionary() -> [String : Any]? {
        return Bundle.main.infoDictionary
    }
}

// MARK: ===== String (沙盒目录) =====
public extension String {
    // MARK: Document 目录
    /// Document 目录
    static func getDocumentPath() -> String {
        let documentPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documnetPath = documentPaths[0]
        return documnetPath
    }
    
    // MARK: Library 目录
    /// Library 目录
    static func getLibraryPath() -> String {
        let libraryPaths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let libraryPath = libraryPaths[0]
        return libraryPath
    }
    
    // MARK: Temp 目录
    /// Temp 目录
    static func getTempPath() -> String {
        let tempPath = NSTemporaryDirectory()
        return tempPath
    }
    
    // MARK: Library/Caches目录
    /// Library/Caches目录
    static func getLibraryCachePath() -> String {
        let cachePaths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cachePath = cachePaths[0]
        return cachePath
    }
}

// MARK: ===== String (文件、类型转换) =====
public extension String {
    // MARK: JsonString 转 NSDictionary
    /// JsonString 转 NSDictionary
    func toDictionary() -> NSDictionary {
        if let jsonData: Data = self.data(using: .utf8) {
            let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
            if let newDict: NSDictionary = dict as? NSDictionary {
                return newDict
            }
        }
        return NSDictionary()
    }
    
    // MARK: JsonString 转 NSArray
    /// JsonString 转 NSArray
    func toArray() -> NSArray {
        if let jsonData: Data = self.data(using: .utf8) {
            let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
            if let newArray: NSArray = array as? NSArray {
                return newArray
            }
        }
        return NSArray()
    }
    
    // MARK: NSDictionary 转 JsonString
    /// NSDictionary 转 JsonString
    static func dictionaryToJson(dictionary: NSDictionary) -> String {
        if !JSONSerialization.isValidJSONObject(dictionary) {
            print("无法解析出JSONString")
            return ""
        }
        let data: NSData = try! JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData
        let JSONString: String = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) as? String ?? ""
        return JSONString
    }
    
    // MARK: NSArray 转 JsonString
    /// NSArray 转 JsonString
    static func arrayToJson(array: NSArray) -> String {
        if !JSONSerialization.isValidJSONObject(array) {
            print("无法解析出JSONString")
            return ""
        }
        let data: NSData = try! JSONSerialization.data(withJSONObject: array, options: []) as NSData
        let JSONString: NSString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) ?? ""
        return JSONString as String
    }
    
    // MARK: 将数据转成json字符串
    /// 将数据转成json字符串
    static func jsonString(from object : Any) -> String? {
        if JSONSerialization.isValidJSONObject(object) {
            do {
                let data = try JSONSerialization.data(withJSONObject: object)
                return  String(data: data, encoding: String.Encoding(rawValue: NSUTF8StringEncoding))
            } catch  {
                print("转换json字符串失败")
            }
        }
        return nil
    }
    
    // MARK: Dictionary -> Data
    /// Dictionary -> Data
    static func dictionaryToData(jsonDic: Dictionary<String, Any>) -> Data? {
        if !JSONSerialization.isValidJSONObject(jsonDic) {
            print("解析失败：不是一个有效的json对象！")
            return nil
        }
        let data = try? JSONSerialization.data(withJSONObject: jsonDic, options: [])
        return data
    }
    
    // MARK: Data -> Dictionary
    /// Data -> Dictionary
    static func dataToDictionary(data: Data) -> Dictionary<String, Any>? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            let dic = json as? Dictionary<String, Any>
            return dic
        } catch _ {
            print("Data -> Dictionary 解析失败！")
            return nil
        }
    }
    
    // MARK: Dictionary 转 model
    /// Dictionary 转 model
    static func performTransToModelObject<T: Decodable>(type: T.Type,
                                                        dictionary: Dictionary<String, Any>) throws -> T? {
        do {
            if let jsonData: Data = String.dictionaryToData(jsonDic: dictionary) {
                let obj = try JSONDecoder().decode(type.self, from: jsonData)
                return obj
            }
        } catch {
            print("Decode Error>>> \(error)")
        }
        return nil
    }
    
    // MARK: NSArray 转 model
    /// NSArray 转 model
    static func performTransToModelObject<T: Decodable>(type: T.Type,
                                                        array: NSArray) throws -> T? {
        do {
            let json = String.arrayToJson(array: array)
            let dictionary: Dictionary<String, Any> = json.dictionary ?? [:]
            if let jsonData: Data = String.dictionaryToData(jsonDic: dictionary) {
                let obj = try JSONDecoder().decode(type.self, from: jsonData)
                return obj
            }
        } catch {
            print("Decode Error>>> \(error)")
        }
        return nil
    }
    
    // MARK: plist文件 转 Array
    /// plist文件 转 Array
    static func getArrayFormFile(fileName: String,
                                 fileType: String = ".plist") -> [Any]? {
        let finalPath: String = getFilePath(fileName: fileName, fileType: fileType)
        if let array: [Any] = NSArray(contentsOfFile: finalPath) as? [Any] {
            return array
        }
        return nil
    }
    
    // MARK: plist文件 转 Dictionary
    /// plist文件 转 Dictionary
    static func getDictionaryFormFile(fileName: String,
                                      fileType: String = ".plist") -> [String: Any]? {
        let finalPath: String = getFilePath(fileName: fileName, fileType: fileType)
        if let dict: [String: Any] = NSDictionary(contentsOfFile: finalPath) as? [String: Any] {
            return dict
        }
        return nil
    }
    
    static func getFilePath(fileName: String,
                            fileType: String = ".plist") -> String {
        let path = Bundle.main.bundlePath
        let fileName: String = "\(fileName)\(fileType)"
        let finalPath: String = (path as NSString).appendingPathComponent(fileName)
        return finalPath
    }
    
    // MARK: json文件 转 Dictionary
    /// json文件 转 Dictionary
    static func getDictionaryFormJsonFile(fileName: String) -> [String: Any]? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            let url = URL(fileURLWithPath: path)
            do {
                let data = try Data(contentsOf: url)
                let jsonData: Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                let jsonDictionary: [String: Any]? = jsonData as? [String: Any]
                return jsonDictionary
            } catch let error as Error? {
                print("==> \(fileName).json 文件序列化错误！Error: \(error.debugDescription)")
            }
        }
        return nil
    }
}

// MARK: ===== String (常用方法) =====
public extension String {
    // MARK: 随机字符串
    static func randomString(length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    // MARK: 随机字符串 (纯数字)
    static func randomIntString(length: Int) -> Int {
        let letters : NSString = "0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return Int(randomString) ?? 0
    }
    
    // MARK: 文本的高度
    /// 文本的高度
    func textHeight(font: UIFont,
                    width: CGFloat) -> CGFloat {
        
        let height = self.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)),
                                       options: NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesDeviceMetrics.rawValue | NSStringDrawingOptions.usesFontLeading.rawValue | NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.truncatesLastVisibleLine.rawValue),
                                       attributes: [NSAttributedString.Key.font: font], context: nil).size.height
        return height
    }
    
    // MARK: 文本的宽度
    /// 文本的宽度
    func textWidth(font: UIFont,
                   height: CGFloat) -> CGFloat {
        
        let width = self.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height),
                                      options: NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesFontLeading.rawValue | NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.truncatesLastVisibleLine.rawValue)
                                      , attributes: [NSAttributedString.Key.font:font], context: nil).size.width
        return width
    }
    
    // MARK: 文本绘制
    /// 文本绘制
    func drawText(text: NSString,
                  rect: CGRect,
                  font: UIFont,
                  color: UIColor) {
        let textAttributedString: Dictionary<NSAttributedString.Key, Any> = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color]
        text.draw(in: rect, withAttributes: textAttributedString)
    }
    
    // MARK: 去除字符串中的所有空格
    /// 去除字符串中的所有空格
    func trimmingAllWhiteSpaces() -> String {
        let tempStr = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return tempStr.replacingOccurrences(of: " ", with: "")
    }
    
    // MARK: 去除首尾空格
    /// 去除首尾空格
    func trimmingFirstLastSpaces() -> String {
        let tempStr = self.trimmingCharacters(in: .whitespaces)
        return tempStr
    }
    
    // MARK: 判断是否是空符串（去除空格之后）
    /// 判断是否是空符串（去除空格之后）
    func isEmptyString() -> Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: 移除末尾0
    /// 移除末尾0
    static func removeZero(double: Double,
                           decimal: Int = 2) -> String {
        let string = String(format: "%.\(decimal)f", double)
        return removeZero(string: string)
    }
    
    /// 移除末尾0
    static func removeZero(string: String) -> String {
        let result = string
        if result.contains(".") {
            var newResult = result
            var i = 1
            while i < result.count {
                if newResult.hasSuffix("0") {
                    newResult.remove(at: newResult.index(before: newResult.endIndex))
                    i = i + 1
                } else {
                    break
                }
            }
            if newResult.hasSuffix(".") {
                newResult.remove(at: newResult.index(before: newResult.endIndex))
            }
            return newResult
        } else {
            return result
        }
    }
    
    // MARK: 字符串转数字
    /// 转 Int
    func toInt() -> Int {
        var value: Int = 0
        value = Int(self) ?? 0
        return value
    }
    
    /// 转 Double
    func toDouble() -> Double {
        var value: Double = 0.0
        value = Double(self) ?? 0.0
        return value
    }
    
    /// 转 Decimal String
    func toDecimal() -> String {
        let largeNumber: NSNumber = NSDecimalNumber(string: self)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: largeNumber) ?? ""
        return formattedNumber
    }
    
    // MARK: 字符串替换
    /// 字符串替换
    static func stringReplace(text: String,
                              oldStr: String,
                              newStr: String) -> String {
        return text.replacingOccurrences(of: oldStr, with: newStr)
    }
    
    /// 智能获取通讯录分组标题
    func contactGroupTitle() -> String {
        guard !self.isEmpty else { return "#" }
        
        let firstChar = String(self.prefix(1))
        
        // 1. 英文字母直接返回大写
        if firstChar.range(of: "^[A-Za-z]$", options: .regularExpression) != nil {
            return firstChar.uppercased()
        }
        
        // 2. 数字返回 #
        if firstChar.range(of: "^[0-9]$", options: .regularExpression) != nil {
            return "#"
        }
        
        // 3. 中文字符尝试获取拼音
        if isChineseCharacter(firstChar) {
            if let pinyinFirstLetter = getChinesePinyinFirstLetter(firstChar) {
                return pinyinFirstLetter
            }
        }
        
        // 4. 其他字符（包括日文、韩文等）使用原始字符
        return firstChar
    }
    
    private func isChineseCharacter(_ char: String) -> Bool {
        // 简单的 Unicode 范围判断
        guard let scalar = char.unicodeScalars.first else { return false }
        return scalar.value >= 0x4E00 && scalar.value <= 0x9FFF
    }
    
    private func getChinesePinyinFirstLetter(_ chinese: String) -> String? {
        let mutableString = NSMutableString(string: chinese) as CFMutableString
        
        // 转换为拼音
        CFStringTransform(mutableString, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        
        let pinyin = mutableString as String
        
        // 获取首字母
        if let firstLetter = pinyin.uppercased().first {
            return String(firstLetter)
        }
        
        return nil
    }
}

// MARK: ===== String (加解密相关) =====
public extension String {
    // MARK: 将原始的url编码为合法的url
    /// 将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
                .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    // MARK: 将编码后的url转换回原始的url
    /// 将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
    
    // MARK: Base64 转 String
    /// Base64 转 String
    func base64Decoded() -> String {
        var stringWithDecode: String = ""
        if let base64Data = NSData(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0)) {
            // 对NSData数据进行UTF8解码
            stringWithDecode = NSString(data: base64Data as Data, encoding: NSASCIIStringEncoding) as? String ?? ""
        }
        return stringWithDecode
    }
    
    // MARK: String 转 Base64
    /// String 转 Base64
    func base64String() -> String {
        let plainData = self.data(using: .utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String ?? ""
    }
    
    // MARK: 异或加密
    // 异或加密
    func xorEncrypt(secretKey: String) -> String {
        let key = secretKey as NSString
        let input = self as NSString
        let chars = (0..<input.length).map({
            input.character(at: $0) ^ key.character(at: $0 % key.length)
        })
        return NSString(characters: chars, length: chars.count) as String
    }
}

// MARK: - ===== String (正则表达式) =====
public extension String {
    // MARK: 验证正则表达式
    /// 验证正则表达式
    func predicateValue(rgex: String) -> Bool {
        let checker: NSPredicate = NSPredicate(format: "SELF MATCHES %@", rgex)
        return checker.evaluate(with: self)
    }
    
    // MARK: 是否为邮箱
    /// 是否为邮箱
    func isEmail() -> Bool {
        if self.count == 0 {
            return false
        }
        let rgex = "^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(.[a-zA-Z0-9_-]+)+$"
        return predicateValue(rgex: rgex)
    }
    
    // MARK: 是否为数字
    /// 是否为数字
    func isNumber() -> Bool {
        let rgex = "^[0-9]+$"
        return predicateValue(rgex: rgex)
    }
    
    // MARK: 判断是否是中文
    /// 判断是否是中文, 这里的中文不包括数字及标点符号
    func isChinese() -> Bool {
        let rgex = "(^[\u{4e00}-\u{9fef}]+$)"
        return predicateValue(rgex: rgex)
    }
    
    // MARK: 字符串为空是，返回‘--’
    /// 字符串为空是，返回‘--’
    func defaultString() -> String {
        if self.count == 0 {
            return "--"
        }
        return self
    }
    
    // MARK: 判断是否全是字母，长度为0返回false
    /// 判断是否全是字母，长度为0返回false
    func isLetters() -> Bool {
        if self.isEmpty {
            return false
        }
        return self.trimmingCharacters(in: NSCharacterSet.letters) == ""
    }
    
    // MARK: 是否包含emoji表情
    /// 是否包含emoji表情
    func isContainsEmoji() -> Bool {
        return self.contains{ $0.isEmoji }
    }
}

// MARK: - 字符串加密
public extension String {
    func caesarEncrypt(shift: Int = 10) -> String {
        return self.map { char -> Character in
            guard let ascii = char.asciiValue else { return char }
            
            let a: UInt8
            let z: UInt8
            
            if ascii >= 65 && ascii <= 90 {
                a = 65
                z = 90
            } else if ascii >= 97 && ascii <= 122 {
                a = 97
                z = 122
            } else if ascii >= 48 && ascii <= 57 {
                a = 48
                z = 57
            } else {
                return char
            }
            
            let offset = UInt8((Int(ascii - a) + shift + Int(z - a + 1)) % Int(z - a + 1))
            return Character(UnicodeScalar(a + offset))
        }.reduce("") { $0 + String($1) }
    }
    
    func caesarDecrypt(shift: Int = 10) -> String {
        return self.caesarEncrypt(shift: -shift)
    }
}

// MARK: -
extension Character {
    /// 简单的emoji是一个标量，以emoji的形式呈现给用户
    var isSimpleEmoji: Bool {
        guard let firstProperties = unicodeScalars.first?.properties else {
            return false
        }
        return unicodeScalars.count == 1 &&
        (firstProperties.isEmojiPresentation ||
         firstProperties.generalCategory == .otherSymbol)
    }
    
    /// 检查标量是否将合并到emoji中
    var isCombinedIntoEmoji: Bool {
        return unicodeScalars.count > 1 &&
        unicodeScalars.contains { $0.properties.isJoinControl || $0.properties.isVariationSelector }
    }
    
    /// 是否为emoji表情
    /// - Note: http://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji
    var isEmoji: Bool {
        return isSimpleEmoji || isCombinedIntoEmoji
    }
}

// MARK: - ======== 富文本字符串 ========
public extension NSMutableAttributedString {
    /// 快捷初始化
    convenience init(_ text: String,
                     attributes: ((AttributesItem) -> Void)? = nil) {
        let item = AttributesItem()
        attributes?(item)
        self.init(string: text, attributes: item.attributes)
    }
    
    /// 添加字符串并为此段添加对应的Attribute
    @discardableResult
    func addText(_ text: String,
                 attributes: ((AttributesItem) -> Void)? = nil) -> NSMutableAttributedString {
        let item = AttributesItem()
        attributes?(item)
        append(NSMutableAttributedString(string: text, attributes: item.attributes))
        return self
    }
    
    /// 添加Attribute作用于当前整体字符串，如果不包含传入的attribute，则增加当前特征
    @discardableResult
    func addAttributes(_ attributes: (AttributesItem) -> Void) -> NSMutableAttributedString {
        let item = AttributesItem()
        attributes(item)
        enumerateAttributes(in: NSRange(string.startIndex ..< string.endIndex, in: string), options: .reverse) { oldAttribute, range, _ in
            var newAtt = oldAttribute
            for item in item.attributes where !oldAttribute.keys.contains(item.key) {
                newAtt[item.key] = item.value
            }
            addAttributes(newAtt, range: range)
        }
        return self
    }
    
    /// 添加图片
    @discardableResult
    func addImage(_ image: UIImage?, _ bounds: CGRect) -> NSMutableAttributedString {
        let attch = NSTextAttachment()
        attch.image = image
        attch.bounds = bounds
        append(NSAttributedString(attachment: attch))
        return self
    }
}

public extension NSAttributedString {
    class AttributesItem {
        private(set) var attributes = [NSAttributedString.Key: Any]()
        private(set) lazy var paragraphStyle = NSMutableParagraphStyle()
        /// 字体
        @discardableResult
        func font(_ value: UIFont) -> AttributesItem {
            attributes[.font] = value
            return self
        }
        
        /// 字体颜色
        @discardableResult
        func foregroundColor(_ value: UIColor) -> AttributesItem {
            attributes[.foregroundColor] = value
            return self
        }
        
        /// 斜体
        @discardableResult
        func oblique(_ value: CGFloat) -> AttributesItem {
            attributes[.obliqueness] = value
            return self
        }
        
        /// 文本横向拉伸属性，正值横向拉伸文本，负值横向压缩文本
        @discardableResult
        func expansion(_ value: CGFloat) -> AttributesItem {
            attributes[.expansion] = value
            return self
        }
        
        /// 字间距
        @discardableResult
        func kern(_ value: CGFloat) -> AttributesItem {
            attributes[.kern] = value
            return self
        }
        
        /// 删除线
        @discardableResult
        func strikeStyle(_ value: NSUnderlineStyle) -> AttributesItem {
            attributes[.strikethroughStyle] = value.rawValue
            return self
        }
        
        /// 删除线颜色
        @discardableResult
        func strikeColor(_ value: UIColor) -> AttributesItem {
            attributes[.strikethroughColor] = value
            return self
        }
        
        /// 下划线
        @discardableResult
        func underlineStyle(_ value: NSUnderlineStyle) -> AttributesItem {
            attributes[.underlineStyle] = value.rawValue
            return self
        }
        
        /// 下划线颜色
        @discardableResult
        func underlineColor(_ value: UIColor) -> AttributesItem {
            attributes[.underlineColor] = value
            return self
        }
        
        /// 设置基线偏移值，正值上偏，负值下偏
        @discardableResult
        func baselineOffset(_ value: CGFloat) -> AttributesItem {
            attributes[.baselineOffset] = value
            return self
        }
        
        /// 居中方式
        @discardableResult
        func alignment(_ value: NSTextAlignment) -> AttributesItem {
            paragraphStyle.alignment = value
            attributes[.paragraphStyle] = paragraphStyle
            return self
        }
        
        /// 字符截断类型
        @discardableResult
        func lineBreakMode(_ value: NSLineBreakMode) -> AttributesItem {
            paragraphStyle.lineBreakMode = value
            attributes[.paragraphStyle] = paragraphStyle
            return self
        }
        
        /// 行间距
        @discardableResult
        func lineSpacing(_ value: CGFloat) -> AttributesItem {
            paragraphStyle.lineSpacing = value
            attributes[.paragraphStyle] = paragraphStyle
            return self
        }
        
        /// 最小行高
        @discardableResult
        func minimumLineHeight(_ value: CGFloat) -> AttributesItem {
            paragraphStyle.minimumLineHeight = value
            attributes[.paragraphStyle] = paragraphStyle
            return self
        }
        
        /// 最大行高
        @discardableResult
        func maximumLineHeight(_ value: CGFloat) -> AttributesItem {
            paragraphStyle.maximumLineHeight = value
            attributes[.paragraphStyle] = paragraphStyle
            return self
        }
        
        /// 段落间距
        @discardableResult
        func paragraphSpacing(_ value: CGFloat) -> AttributesItem {
            paragraphStyle.paragraphSpacing = value
            attributes[.paragraphStyle] = paragraphStyle
            return self
        }
    }
}
