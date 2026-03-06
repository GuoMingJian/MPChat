//
//  SecureStorageManager.swift
//  MJKit
//
//  Created by 郭明健 on 2025/10/15.
//

import Foundation
import Security

public final class SecureStorageManager {
    private init() {}
    
    public static let shared = SecureStorageManager()
    
    public func storeString(_ value: String, forKey key: String) {
        guard let encodedData = value.data(using: .utf8) else { return }
        
        removeValue(key)
        let keychainQuery: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecValueData as String   : encodedData
        ]
        
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    public func retrieveString(_ key: String) -> String? {
        let keychainQuery: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]
        
        var queryResult: AnyObject?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &queryResult)
        
        guard status == errSecSuccess, let retrievedData = queryResult as? Data else { return nil }
        return String(data: retrievedData, encoding: .utf8)
    }
    
    public func removeValue(_ key: String) {
        let keychainQuery: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key
        ]
        SecItemDelete(keychainQuery as CFDictionary)
    }
    
    public func storeObject<T: Codable>(_ value: T, forKey key: String) {
        let jsonEncoder = JSONEncoder()
        guard let encodedData = try? jsonEncoder.encode(value) else { return }
        
        removeValue(key)
        let keychainQuery: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecValueData as String   : encodedData
        ]
        
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    public func retrieveObject<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        let keychainQuery: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]
        
        var queryResult: AnyObject?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &queryResult)
        
        guard status == errSecSuccess, let retrievedData = queryResult as? Data else { return nil }
        
        let jsonDecoder = JSONDecoder()
        return try? jsonDecoder.decode(type, from: retrievedData)
    }
}

@propertyWrapper
public struct SecureStorage<T: Codable> {
    private let storageKey: String
    
    public init(key: String) {
        self.storageKey = key
    }
    
    public var wrappedValue: T? {
        get {
            return SecureStorageManager.shared.retrieveObject(T.self, forKey: storageKey)
        }
        set {
            if let value = newValue {
                SecureStorageManager.shared.storeObject(value, forKey: storageKey)
            } else {
                SecureStorageManager.shared.removeValue(storageKey)
            }
        }
    }
}
