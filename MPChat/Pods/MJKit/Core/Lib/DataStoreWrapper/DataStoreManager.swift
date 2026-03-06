//
//  DataStoreManager.swift
//  MJKit
//
//  Created by 郭明健 on 2025/10/15.
//

import UIKit

public class DataStoreManager {
    private init() {}
    
    public static let shared = DataStoreManager()
    
    public func storeUserDefault<T: Codable>(_ value: T?, forKey key: String) {
        let userDefaults = UserDefaults.standard
        if let value = value, let data = try? JSONEncoder().encode(value) {
            userDefaults.set(data, forKey: key)
        } else {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    public func retrieveUserDefault<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.data(forKey: key),
              let obj = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return obj
    }
    
    public func removeUserDefault(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    public func storeToFile<T: Codable>(_ object: T?, filename: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        if let object = object, let data = try? JSONEncoder().encode(object) {
            try? data.write(to: fileURL)
        } else {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    public func retrieveFromFile<T: Codable>(_ type: T.Type, filename: String) -> T? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: fileURL),
              let obj = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return obj
    }
    
    public func removeFile(_ filename: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    // MARK: -
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

@propertyWrapper
public struct DefaultsStorage<T: Codable> {
    private let storageKey: String
    private let fallbackValue: T?
    
    public init(key: String, defaultValue: T? = nil) {
        self.storageKey = key
        self.fallbackValue = defaultValue
    }
    
    public var wrappedValue: T? {
        get { DataStoreManager.shared.retrieveUserDefault(T.self, forKey: storageKey) ?? fallbackValue }
        set {
            if let newValue = newValue {
                DataStoreManager.shared.storeUserDefault(newValue, forKey: storageKey)
            } else {
                DataStoreManager.shared.removeUserDefault(forKey: storageKey)
            }
        }
    }
}

@propertyWrapper
public struct FileStorage<T: Codable> {
    private let fileName: String
    private let fallbackValue: T?
    
    public init(filename: String, defaultValue: T? = nil) {
        self.fileName = filename
        self.fallbackValue = defaultValue
    }
    
    public var wrappedValue: T? {
        get { DataStoreManager.shared.retrieveFromFile(T.self, filename: fileName) ?? fallbackValue }
        set { DataStoreManager.shared.storeToFile(newValue, filename: fileName) }
    }
}
