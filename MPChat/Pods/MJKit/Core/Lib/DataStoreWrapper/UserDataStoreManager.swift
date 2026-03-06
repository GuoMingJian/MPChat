//
//  UserDataStoreManager.swift
//  MJKit
//
//  Created by 郭明健 on 2025/10/15.
//

import Foundation

public class UserDataStoreManager {
    private init() {}
    
    public static let shared = UserDataStoreManager()
    private var userKey: String = ""
    
    public func initializeUserId(userId: String) {
        userKey = userId
    }
    
    public func configureUser(userId: String) {
        self.userKey = userId
    }
    
    private func generateUserKey(_ key: String) -> String {
        return "\(userKey)_\(key)"
    }
    
    public func storeUserDefault<T: Codable>(_ object: T?, forKey key: String) {
        let userKey = generateUserKey(key)
        if let object = object, let encodedData = try? JSONEncoder().encode(object) {
            UserDefaults.standard.set(encodedData, forKey: userKey)
        } else {
            UserDefaults.standard.removeObject(forKey: userKey)
        }
    }
    
    public func retrieveUserDefault<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        let userKey = generateUserKey(key)
        guard let retrievedData = UserDefaults.standard.data(forKey: userKey),
              let decodedObject = try? JSONDecoder().decode(T.self, from: retrievedData) else {
            return nil
        }
        return decodedObject
    }
    
    public func removeUserDefault(forKey key: String) {
        let userKey = generateUserKey(key)
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    
    public func clearAllUserDefaults() {
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        for userKey in allKeys where userKey.hasPrefix("\(userKey)_") {
            UserDefaults.standard.removeObject(forKey: userKey)
        }
    }
    
    private func getUserDirectory() -> URL {
        let baseDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let userDirectory = baseDirectory.appendingPathComponent(userKey)
        if !FileManager.default.fileExists(atPath: userDirectory.path) {
            try? FileManager.default.createDirectory(at: userDirectory, withIntermediateDirectories: true)
        }
        return userDirectory
    }
    
    public func storeToFile<T: Codable>(_ object: T?, filename: String) {
        let fileURL = getUserDirectory().appendingPathComponent(filename)
        if let object = object, let encodedData = try? JSONEncoder().encode(object) {
            try? encodedData.write(to: fileURL)
        } else {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    public func retrieveFromFile<T: Codable>(_ type: T.Type, filename: String) -> T? {
        let fileURL = getUserDirectory().appendingPathComponent(filename)
        guard let retrievedData = try? Data(contentsOf: fileURL),
              let decodedObject = try? JSONDecoder().decode(T.self, from: retrievedData) else {
            return nil
        }
        return decodedObject
    }
    
    public func removeFile(_ filename: String) {
        let fileURL = getUserDirectory().appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    public func clearAllUserFiles() {
        let userDirectory = getUserDirectory()
        if let fileList = try? FileManager.default.contentsOfDirectory(atPath: userDirectory.path) {
            for fileName in fileList {
                let fileURL = userDirectory.appendingPathComponent(fileName)
                try? FileManager.default.removeItem(at: fileURL)
            }
        }
    }
    
    public func clearAllUserData() {
        clearAllUserDefaults()
        clearAllUserFiles()
    }
}

@propertyWrapper
public struct UserDefaultsStorage<T: Codable> {
    private let storageKey: String
    private let fallbackValue: T?
    
    public init(key: String, defaultValue: T? = nil) {
        self.storageKey = key
        self.fallbackValue = defaultValue
    }
    
    public var wrappedValue: T? {
        get {
            UserDataStoreManager.shared.retrieveUserDefault(T.self, forKey: storageKey) ?? fallbackValue
        }
        set {
            UserDataStoreManager.shared.storeUserDefault(newValue, forKey: storageKey)
        }
    }
}

@propertyWrapper
public struct UserFileStorage<T: Codable> {
    private let fileName: String
    private let fallbackValue: T?
    
    public init(filename: String, defaultValue: T? = nil) {
        self.fileName = filename
        self.fallbackValue = defaultValue
    }
    
    public var wrappedValue: T? {
        get {
            UserDataStoreManager.shared.retrieveFromFile(T.self, filename: fileName) ?? fallbackValue
        }
        set {
            UserDataStoreManager.shared.storeToFile(newValue, filename: fileName)
        }
    }
}
