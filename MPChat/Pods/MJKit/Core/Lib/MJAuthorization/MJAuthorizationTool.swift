
import UIKit
import Photos
import AVFoundation
import Contacts
import EventKit
import CoreBluetooth

public enum MJAuthorizationStatus: Int {
    case notDetermined = 0
    case restricted = 1
    case denied = 2
    case authorized = 3
    case limited = 4
    case disable = 5
}

public enum KPhotoAccessLevel: Int {
    case addOnly = 1
    case readWrite = 2
}

public enum KLocationAuthLevel: Int {
    case whenInUse = 1
    case always = 2
}

public class MJAuthorizationTool: NSObject, CLLocationManagerDelegate, CBCentralManagerDelegate {
    
    private static let instance: MJAuthorizationTool = MJAuthorizationTool()
    private var locationCompletionHandler: ((Bool) -> Void)?
    private var bluetoothCompletionHandler: ((Bool) -> Void)?
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    private lazy var bluetoothManager: CBCentralManager = {
        let manager = CBCentralManager()
        manager.delegate = self
        return manager
    }()
    
    // MARK: - 获取权限状态
    
    /// 获取相册权限状态
    /// - Parameter level: 权限等级
    /// - Returns: 权限状态
    public static func photoAuthorizationStatus(level: KPhotoAccessLevel = .readWrite) -> MJAuthorizationStatus {
        var status: PHAuthorizationStatus!
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: level == .addOnly ? .addOnly : .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        return MJAuthorizationStatus.init(rawValue: status.rawValue)!
    }
    
    /// 获取相机权限状态
    /// - Returns: 权限状态
    public static func cameraAuthorizationStatus() -> MJAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return MJAuthorizationStatus.init(rawValue: status.rawValue)!
    }
    
    /// 获取麦克风权限状态
    /// - Returns: 权限状态
    public static func micAuthorizationStatus() -> MJAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        return MJAuthorizationStatus.init(rawValue: status.rawValue)!
    }
    
    /// 获取通讯录权限状态
    /// - Returns: 权限状态
    public static func contactAuthorizationStatus() -> MJAuthorizationStatus {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        return MJAuthorizationStatus.init(rawValue: status.rawValue)!
    }
    
    /// 获取日历权限状态
    /// - Parameter type: 权限类型
    /// - Returns: 权限状态
    public static func calendarAuthorizationStatus(type: EKEntityType) -> MJAuthorizationStatus {
        let status = EKEventStore.authorizationStatus(for: type)
        return MJAuthorizationStatus.init(rawValue: status.rawValue)!
    }
    
    /// 获取定位权限状态
    /// - Returns: 权限状态
    public static func locationAuthorizationStatus() -> MJAuthorizationStatus {
        var status: CLAuthorizationStatus = .denied
        if #available(iOS 14.0, *) {
            let locationManager =  CLLocationManager()
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        return MJAuthorizationStatus.init(rawValue: Int(status.rawValue)) ?? .denied
    }
    
    /// 获取推送权限状态
    /// - Returns: 权限状态
    public static func notificationAuthorizationStatus() -> MJAuthorizationStatus {
        if #available(iOS 10.0, *) {
            var status: MJAuthorizationStatus = .denied
            let sema = DispatchSemaphore(value: 0)
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                let rawValue = settings.authorizationStatus.rawValue
                status = MJAuthorizationStatus.init(rawValue: rawValue == 0 ? 0 : rawValue + 1) ?? .denied
                sema.signal()
            }
            sema.wait()
            return status
        } else {
            let types = UIApplication.shared.currentUserNotificationSettings?.types
            if types == UIUserNotificationType.init(rawValue: 0) {
                return .denied
            } else {
                return .authorized
            }
        }
    }
    
    /// 获取蓝牙权限状态
    /// - Returns: 权限状态
    public static func bluetoothAuthorizationStatus() -> MJAuthorizationStatus {
        if #available(iOS 13.0, *) {
            if #available(iOS 13.1, *) {
                let status = CBCentralManager.authorization
                return MJAuthorizationStatus(rawValue: status.rawValue) ?? .denied
            } else {
                let status = CBCentralManager().authorization
                return MJAuthorizationStatus(rawValue: status.rawValue) ?? .denied
            }
        } else {
            let status = CBPeripheralManager.authorizationStatus()
            return MJAuthorizationStatus(rawValue: status.rawValue) ?? .denied
        }
    }
    
    // MARK: - 获取权限授权
    
    /// 获取相册授权
    /// - Parameters:
    ///   - level: 权限等级
    ///   - completionHandler: 授权回调
    public static func requestPhotoAuthorization(level: KPhotoAccessLevel = .readWrite, completionHandler: @escaping (Bool) -> Void) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: level == .addOnly ? .addOnly : .readWrite) { status in
                completionHandler(status == .authorized)
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                completionHandler(status == .authorized)
            }
        }
    }
    
    /// 获取相机授权
    /// - Parameter completionHandler: 授权回调
    public static func requsetCameraAuthorization(completionHandler: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: completionHandler)
    }
    
    /// 获取麦克风授权
    /// - Parameter completionHandler: 授权回调
    public static func requestMicAuthorization(completionHandler: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio, completionHandler: completionHandler)
    }
    
    /// 获取通讯录授权
    /// - Parameter completionHandler: 授权回调
    public static func requestContactAuthorization(completionHandler: @escaping (Bool) -> Void) {
        CNContactStore().requestAccess(for: .contacts) { granted, error in
            if error == nil {
                completionHandler(granted)
            } else {
                completionHandler(false)
            }
        }
    }
    
    /// 获取日历授权
    /// - Parameters:
    ///   - type: 授权类型
    ///   - completionHandler: 授权回调
    public static func requestCalendarAuthorization(type: EKEntityType, completionHandler: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        if #available(iOS 17, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                if error != nil {
                    completionHandler(false)
                } else {
                    completionHandler(granted)
                }
            }
        } else {
            eventStore.requestAccess(to: type) { granted, error in
                if error == nil {
                    completionHandler(granted)
                } else {
                    completionHandler(false)
                }
            }
        }
    }
    
    /// 获取定位授权
    /// - Parameters:
    ///   - level: 授权等级
    ///   - completionHandler: 授权回调
    public static func requestLocationAuthorization(level: KLocationAuthLevel, completionHandler: @escaping (Bool) -> Void) {
        MJAuthorizationTool.instance.locationCompletionHandler = completionHandler
        if level == .whenInUse {
            instance.locationManager.requestWhenInUseAuthorization()
        } else {
            instance.locationManager.requestAlwaysAuthorization()
            instance.locationManager.allowsBackgroundLocationUpdates = true
        }
    }
    
    /// 获取蓝牙授权
    /// - Parameter completionHandler: 授权回调
    public static func requestBluetoothAuthorization(completionHandler: @escaping (Bool) -> Void) {
        MJAuthorizationTool.instance.bluetoothCompletionHandler = completionHandler
        instance.bluetoothManager.scanForPeripherals(withServices: nil)
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = MJAuthorizationTool.locationAuthorizationStatus()
        if status == .authorized || status == .limited {
            self.locationCompletionHandler?(true)
            self.locationCompletionHandler = nil
        } else {
            self.locationCompletionHandler?(false)
            self.locationCompletionHandler = nil
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.locationCompletionHandler?(true)
            self.locationCompletionHandler = nil
        } else {
            self.locationCompletionHandler?(false)
            self.locationCompletionHandler = nil
        }
    }
    
    // MARK: - CBPeripheralManagerDelegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let status = MJAuthorizationTool.bluetoothAuthorizationStatus()
        if status == .authorized || status == .limited {
            self.bluetoothCompletionHandler?(true)
            self.bluetoothCompletionHandler = nil
        } else {
            self.bluetoothCompletionHandler?(false)
            self.bluetoothCompletionHandler = nil
        }
    }
    
}
