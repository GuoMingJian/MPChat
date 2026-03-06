
import UIKit

public enum MJAuthorizationType {
    case photoAddOnly       // 保存图片到本地
    case photoReadWrite     // 选择图片或保存图片
    case camera             // 相机
    case mic                // 麦克风
    case contact            // 联系人
    case event              // 日历
    case reminder           // 提醒
    case locationWhenInUse  // 定位
    case locationAlways     // 定位
    case bluetooth          // 蓝牙
}

public struct MJAuthorization {
    /// 获取权限
    /// - Parameters:
    ///   - type: 权限类型
    ///   - success: 获取权限成功
    ///   - failure: 获取权限失败（只有定位服务不可用时才会有回调）
    public static func requestAuth(type: MJAuthorizationType,
                                   success: @escaping () -> Void,
                                   failure: (() -> Void)? = nil) {
        switch type {
        case .photoAddOnly:
            let status = MJAuthorizationTool.photoAuthorizationStatus(level: .addOnly)
            switch status {
            case .notDetermined:
                MJAuthorizationTool.requestPhotoAuthorization(level: .addOnly) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            success()
                        } else {
                            showDeniedAlert(type: .photoAddOnly)
                        }
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    showDeniedAlert(type: .photoAddOnly)
                }
            case .authorized, .limited:
                DispatchQueue.main.async {
                    success()
                }
            default :
                break
            }
        case .photoReadWrite:
            let status = MJAuthorizationTool.photoAuthorizationStatus(level: .readWrite)
            switch status {
            case .notDetermined:
                MJAuthorizationTool.requestPhotoAuthorization(level: .readWrite) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            success()
                        } else {
                            showDeniedAlert(type: .photoReadWrite)
                        }
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    showDeniedAlert(type: .photoReadWrite)
                }
            case .authorized, .limited:
                DispatchQueue.main.async {
                    success()
                }
            default :
                break
            }
        case .camera:
            let status = MJAuthorizationTool.cameraAuthorizationStatus()
            switch status {
            case .notDetermined:
                MJAuthorizationTool.requsetCameraAuthorization { granted in
                    DispatchQueue.main.async {
                        if granted {
                            success()
                        } else {
                            showDeniedAlert(type: .camera)
                        }
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    showDeniedAlert(type: .camera)
                }
            case .authorized:
                DispatchQueue.main.async {
                    success()
                }
            default:
                break
            }
        case .mic:
            let status = MJAuthorizationTool.micAuthorizationStatus()
            switch status {
            case .notDetermined:
                MJAuthorizationTool.requestMicAuthorization { granted in
                    DispatchQueue.main.async {
                        if granted {
                            success()
                        } else {
                            showDeniedAlert(type: .mic)
                        }
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    showDeniedAlert(type: .mic)
                }
            case .authorized:
                DispatchQueue.main.async {
                    success()
                }
            default:
                break
            }
        case .contact:
            let status = MJAuthorizationTool.contactAuthorizationStatus()
            switch status {
            case .notDetermined:
                MJAuthorizationTool.requestContactAuthorization { granted in
                    DispatchQueue.main.async {
                        if granted {
                            success()
                        } else {
                            showDeniedAlert(type: .contact)
                        }
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    showDeniedAlert(type: .contact)
                }
            case .authorized:
                DispatchQueue.main.async {
                    success()
                }
            default:
                break
            }
        case .event:
            let status = MJAuthorizationTool.calendarAuthorizationStatus(type: .event)
            switch status {
            case .notDetermined:
                MJAuthorizationTool.requestCalendarAuthorization(type: .event) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            success()
                        } else {
                            showDeniedAlert(type: .event)
                        }
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    showDeniedAlert(type: .event)
                }
            case .authorized:
                DispatchQueue.main.async {
                    success()
                }
            default:
                break
            }
        case .reminder:
            let status = MJAuthorizationTool.calendarAuthorizationStatus(type: .reminder)
            switch status {
            case .notDetermined:
                MJAuthorizationTool.requestCalendarAuthorization(type: .reminder) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            success()
                        } else {
                            showDeniedAlert(type: .reminder)
                        }
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    showDeniedAlert(type: .reminder)
                }
            case .authorized:
                DispatchQueue.main.async {
                    success()
                }
            default:
                break
            }
        case .locationWhenInUse, .locationAlways:
            let status = MJAuthorizationTool.locationAuthorizationStatus()
            switch status {
            case .notDetermined:
                MJAuthorizationTool.requestLocationAuthorization(level: type == .locationWhenInUse ? .whenInUse : .always ) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            success()
                        } else {
                            showDeniedAlert(type: type)
                        }
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    showDeniedAlert(type: type)
                }
            case .authorized, .limited:
                DispatchQueue.main.async {
                    success()
                }
            case .disable:
                DispatchQueue.main.async {
                    if failure != nil {
                        failure!()
                    }
                }
            default:
                break
            }
        case .bluetooth:
            let status = MJAuthorizationTool.bluetoothAuthorizationStatus()
            switch status {
            case .notDetermined:
                MJAuthorizationTool.requestBluetoothAuthorization { granted in
                    DispatchQueue.main.async {
                        if granted {
                            success()
                        } else {
                            showDeniedAlert(type: type)
                        }
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    showDeniedAlert(type: type)
                }
            case .authorized, .limited:
                DispatchQueue.main.async {
                    success()
                }
            case .disable:
                DispatchQueue.main.async {
                    if failure != nil {
                        failure!()
                    }
                }
            default:
                break
            }
        }
    }
    
    /// 展示授权弹框
    /// - Parameter type: 授权类型
    public static func showDeniedAlert(type: MJAuthorizationType) {
        let appName = (Bundle.main.infoDictionary!["CFBundleDisplayName"] ?? Bundle.main.infoDictionary!["CFBundleName"]) as! String
        var title = ""
        var description = ""
        switch type {
        case .photoAddOnly:
            title = "PhotoTitle_add"
            description = Bundle.main.infoDictionary!["NSPhotoLibraryAddUsageDescription"] as! String
        case .photoReadWrite:
            title = "PhotoTitle_all"
            description = Bundle.main.infoDictionary!["NSPhotoLibraryUsageDescription"] as! String
        case .camera:
            title = "CameraTitle"
            description = Bundle.main.infoDictionary!["NSCameraUsageDescription"] as! String
        case .mic:
            title = "MicTitle"
            description = Bundle.main.infoDictionary!["NSMicrophoneUsageDescription"] as! String
        case .contact:
            title = "ContactTitle"
            description = Bundle.main.infoDictionary!["NSContactsUsageDescription"] as! String
        case .event:
            title = "EventTitle"
            description = Bundle.main.infoDictionary!["NSCalendarsUsageDescription"] as! String
        case .reminder:
            title = "ReminderTitle"
            description = Bundle.main.infoDictionary!["NSRemindersUsageDescription"] as! String
        case .locationWhenInUse:
            title = "LocationTitle"
            description = Bundle.main.infoDictionary!["NSLocationWhenInUseUsageDescription"] as! String
        case .locationAlways:
            title = "LocationTitle"
            description = Bundle.main.infoDictionary!["NSLocationAlwaysUsageDescription"] as! String
        case .bluetooth:
            title = "BleTitle"
            description = Bundle.main.infoDictionary!["NSBluetoothAlwaysUsageDescription"] as! String
        }
        let alert = UIAlertController(title: String(format: title.mj_localizedAuth(), appName) , message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "PermissionGo".mj_localizedAuth(), style: .default, handler: { _ in
                MJAuthorization.openAppSettings()
        }))
        // 适配iPad
        if let popoverPresentationController = alert.popoverPresentationController {
            if let currentVC = currentViewController() {
                popoverPresentationController.sourceView = currentVC.view
                popoverPresentationController.sourceRect = CGRect(x: currentVC.view.bounds.midX, y: currentVC.view.bounds.midY, width: 0, height: 0)
                popoverPresentationController.permittedArrowDirections = []
            }
        }
        alert.addAction(UIAlertAction(title: "PermissionNot".mj_localizedAuth(), style: .cancel, handler: nil))
        currentViewController()?.present(alert, animated: true)
    }
    
    /// 打开系统设置
    static func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }
        
        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
    
    // MARK: - UIView
    private static func currentWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({ $0 }).first?.windows.first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    private static func currentViewController() -> UIViewController? {
        guard let controller = currentWindow()?.rootViewController else {
            return nil
        }
        return self.currentViewControllerFrom(controller)
    }
    
    private static func currentViewControllerFrom(_ root: UIViewController) -> UIViewController {
        let currentViewController: UIViewController
        if root.presentedViewController != nil {
            return self.currentViewControllerFrom(root.presentedViewController!)
        }
        if root.isKind(of: UITabBarController.classForCoder()) {
            currentViewController = self.currentViewControllerFrom((root as! UITabBarController).selectedViewController!)
        } else if root.isKind(of: UINavigationController.classForCoder()) {
            currentViewController = self.currentViewControllerFrom((root as! UINavigationController).visibleViewController!)
        } else {
            currentViewController = root
        }
        return currentViewController
    }
}

/*
 // 相册保存权限
 NSPhotoLibraryAddUsageDescription = "APP needs permission to save photos and videos to your photo library.";

 // 相册读写权限
 NSPhotoLibraryUsageDescription = "APP requires access to your photo library to send photos and videos in chats.";

 // 相机权限
 NSCameraUsageDescription = "APP needs camera permission to take photos, record videos, and scan QR codes.";

 // 麦克风权限
 NSMicrophoneUsageDescription = "APP needs microphone permission for voice recording, sending voice messages, and voice chats.";

 // 通讯录权限
 NSContactsUsageDescription = "APP requires contact access to quickly find and add friends.";

 // 日历权限
 NSCalendarsUsageDescription = "APP needs access to your calendar to create and manage events.";

 // 提醒事项权限
 NSRemindersUsageDescription = "APP needs access to your reminders to create and manage to-do lists.";

 // 使用时定位权限
 NSLocationWhenInUseUsageDescription = "APP needs access to your location to share it in chats.";

 // 始终定位权限
 NSLocationAlwaysAndWhenInUseUsageDescription = "APP needs access to your location to share it in chats.";

 // 蓝牙权限
 NSBluetoothAlwaysUsageDescription = "APP needs access to Bluetooth to connect with nearby devices.";

 /*
  INFOPLIST_KEY_NSCameraUsageDescription =
  INFOPLIST_KEY_NSContactsUsageDescription =
  INFOPLIST_KEY_NSFaceIDUsageDescription =
  INFOPLIST_KEY_NSLocationAlwaysAndWhenInUseUsageDescription =
  INFOPLIST_KEY_NSLocationAlwaysUsageDescription =
  INFOPLIST_KEY_NSLocationWhenInUseUsageDescription =
  INFOPLIST_KEY_NSMicrophoneUsageDescription =
  INFOPLIST_KEY_NSPhotoLibraryAddUsageDescription =
  INFOPLIST_KEY_NSPhotoLibraryUsageDescription =
  INFOPLIST_KEY_NSCalendarsUsageDescription =
  INFOPLIST_KEY_NSRemindersUsageDescription =
  INFOPLIST_KEY_NSBluetoothAlwaysUsageDescription =
  */
 */
