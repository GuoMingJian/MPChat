//
//  MJRuntime.swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

public func mj_getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(object, key) as? T
}

public func mj_setRetainedAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, _ value: T, _ policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
    objc_setAssociatedObject(object, key, value, policy)
}

public class MJRuntime: NSObject {
    /// 成员变量列表
    @discardableResult
    public static func ivars(_ type: AnyClass) -> [String] {
        var listName = [String]()
        var count: UInt32 = 0
        let ivars = class_copyIvarList(type, &count)
        for i in 0..<count {
            let nameP = ivar_getName(ivars![Int(i)])!
            let name = String(cString: nameP)
            debugPrint("name=\(name)")
            listName.append(name)
        }
        // 方法中有 copy, create,的都需要释放
        free(ivars)
        return listName
    }
    
    /// 获取所有属性的名字
    @discardableResult
    public static func getAllPropertyName(_ aClass: AnyClass) -> [String] {
        var count = UInt32()
        let properties = class_copyPropertyList(aClass, &count)
        var propertyNames = [String]()
        let intCount = Int(count)
        for i in 0 ..< intCount {
            let property: objc_property_t = properties![i]
            guard let propertyName = NSString(utf8String: property_getName(property)) as String? else {
                MJ.printInfo("Couldn't unwrap property name for \(property)")
                break
            }
            propertyNames.append(propertyName)
        }
        free(properties)
        return propertyNames
    }
    
    /// 获取方法列表
    @discardableResult
    public static func methods(from classType: AnyClass) -> [Selector] {
        var methodNum: UInt32 = 0
        var list = [Selector]()
        let methods = class_copyMethodList(classType, &methodNum)
        for index in 0..<numericCast(methodNum) {
            if let met = methods?[index] {
                let selector = method_getName(met)
                debugPrint("\(classType)的方法：\(selector)")
                list.append(selector)
            }
        }
        free(methods)
        return list
    }
}

// MARK: - 交换方法
public extension MJRuntime {
    /// 交换方法
    static func exchangeMethod(target: String,
                               replace: String,
                               class classType: AnyClass) {
        exchangeMethod(selector: Selector(target),
                       replace: Selector(replace),
                       class: classType)
    }
    
    /// 交换方法
    static func exchangeMethod(selector: Selector,
                               replace: Selector,
                               class classType: AnyClass) {
        let select1 = selector
        let select2 = replace
        let select1Method = class_getInstanceMethod(classType, select1)
        let select2Method = class_getInstanceMethod(classType, select2)
        let didAddMethod = class_addMethod(classType, select1, method_getImplementation(select2Method!), method_getTypeEncoding(select2Method!))
        if didAddMethod {
            class_replaceMethod(classType, select2, method_getImplementation(select1Method!), method_getTypeEncoding(select1Method!))
        } else {
            method_exchangeImplementations(select1Method!, select2Method!)
        }
    }
}
