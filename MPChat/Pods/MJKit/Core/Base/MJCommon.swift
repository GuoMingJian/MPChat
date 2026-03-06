
import Foundation

class MJCommon: NSObject {}

// MARK: - MJKit Language
public enum MJLanguage: String {
    case en
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    
    public static var current: MJLanguage = {
        guard let language = Locale.preferredLanguages.first else { return .en }
        
        if language.contains("zh-HK") { return .zhHant }
        if language.contains("zh-Hant") { return .zhHant }
        if language.contains("zh-Hans") { return .zhHans }
        
        return MJLanguage(rawValue: language) ?? .en
    }()
}

public extension String {
    func mj_localizedAuth(_ language: MJLanguage = .current,
                          value: String? = nil,
                          table: String = "Localizable") -> String {
        guard let path = Bundle.authorizeBundle?.path(forResource: language.rawValue, ofType: "lproj") else {
            return self
        }
        return Bundle(path: path)?.localizedString(forKey: self, value: value, table: table) ?? self
    }
    
    func mj_Localized(_ language: MJLanguage = .current,
                      value: String? = nil,
                      table: String = "Localizable") -> String {
        guard let path = Bundle.mjkitBundle?.path(forResource: language.rawValue, ofType: "lproj") else {
            return self
        }
        return Bundle(path: path)?.localizedString(forKey: self, value: value, table: table) ?? self
    }
}

extension Bundle {
    static let authorizeBundle: Bundle? = {
        let containnerBundle = Bundle(for: MJCommon.self)
        return Bundle(path: containnerBundle.path(forResource: "MJAuthorization", ofType: "bundle")!) ?? .main
    }()
    
    static let mjkitBundle: Bundle? = {
        let containnerBundle = Bundle(for: MJCommon.self)
        return Bundle(path: containnerBundle.path(forResource: "MJKit", ofType: "bundle")!) ?? .main
    }()
}

// MARK: - MJKit Images
public extension UIImage {
    /// 获取 MJKit 的 Bundle
    private static var mjKitBundle: Bundle {
        return Bundle(for: MJCommon.self)
    }
    
    /// 从 MJKit.xcassets 加载图片
    static func mj_Image(_ name: String) -> UIImage {
        return UIImage(named: name,
                       in: mjKitBundle,
                       compatibleWith: nil) ?? UIImage()
    }
}

public extension String {
    func mj_Image() -> UIImage {
        return UIImage.mj_Image(self)
    }
}
