//
//  MJUUID.swift
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit
import KeychainAccess

public class MJUUID {
    static let KEYCHAIN_SERVICE: String = String.appBundleId()
    static let UUID_KEY: String = "UUID_KEY"
    
    static func getUUID() -> String {
        let keychain = Keychain(service: KEYCHAIN_SERVICE)
        var uuid: String = ""
        do {
            uuid = try keychain.get(UUID_KEY) ?? ""
        }
        catch let error {
            print("MJUUID error1 ====> \(error)")
        }
        print("uuid ====> 拉取的设备：\(uuid)")
        if uuid.isEmpty {
            uuid = UUID().uuidString
            do {
                try keychain.set(uuid, key: UUID_KEY)
                print("MJUUID new ====> \(uuid)")
            }
            catch let error {
                print("MJUUID error2 ====> \(error)")
                uuid = ""
            }
        }
        return uuid
    }
}
