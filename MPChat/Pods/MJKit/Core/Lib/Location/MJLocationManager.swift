//
//  MJLocationManager.swift
//
//  Created by 郭明健 on 2023/7/29.
//

import UIKit
import CoreLocation

// MARK: - 获取数据格式
public extension MJLocationManager {
    struct MJLocationInfo: Codable {
        public var longitude: Double = -1
        public var latitude: Double = -1
        public var address: String = ""
        public var detailedAddress: String = ""
        
        public init() {}
        
        public init(longitude: Double,
                    latitude: Double,
                    address: String,
                    detailedAddress: String) {
            self.longitude = longitude
            self.latitude = latitude
            self.address = address
            self.detailedAddress = detailedAddress
        }
        
        // 便捷属性：获取CLLocationCoordinate2D
        public var coordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        // 检查位置是否有效
        public var isValid: Bool {
            return longitude != -1 && latitude != -1
        }
    }
}

// MARK: -
public class MJLocationManager: NSObject {
    
    // MARK: - 单例模式
    public static var shared: MJLocationManager {
        struct Static {
            static var instance: MJLocationManager?
            static var onceToken: Int = 0
        }
        
        if Static.instance == nil {
            Static.instance = MJLocationManager()
            
            // 使用异步方式处理授权请求，避免死锁
            DispatchQueue.main.async {
                MJAuthorization.requestAuth(type: .locationWhenInUse) {
                    Static.instance?.setup()
                }
            }
        }
        return Static.instance!
    }
    
    // MARK: - Properties
    /// 定位管理器
    private let locationManager: CLLocationManager = CLLocationManager()
    /// 返回数据 Block
    private var locationBlock: ((_ locationInfo: MJLocationInfo) -> Void)?
    private var failureBlock: (() -> Void)?
    
    /// 地理编码器
    private let geocoder = CLGeocoder()
    
    /// 是否已经配置后台定位
    private var hasConfiguredBackgroundUpdates = false
    
    /// 获取当前授权状态（兼容iOS 14+）
    private var currentAuthorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }
    
    /// 初始化配置
    private func setup() {
        locationManager.delegate = self
        
        /* 定位精度
         kCLLocationAccuracyBestForNavigation ：精度最高，一般用于导航
         kCLLocationAccuracyBest ： 精确度最佳
         kCLLocationAccuracyNearestTenMeters ：精确度10m以内
         kCLLocationAccuracyHundredMeters ：精确度100m以内
         kCLLocationAccuracyKilometer ：精确度1000m以内
         kCLLocationAccuracyThreeKilometers ：精确度3000m以内
         */
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 更新距离（米）
        locationManager.distanceFilter = 5.0
        
        // 检查定位服务是否可用
        guard CLLocationManager.locationServicesEnabled() else {
            print("MJLocationManager: 定位服务不可用")
            return
        }
        
        // 配置后台定位（需要确保有正确的Info.plist配置）
        configureBackgroundLocationUpdates()
    }
    
    /// 配置后台定位更新
    private func configureBackgroundLocationUpdates() {
        // 检查是否在Info.plist中配置了后台定位模式
        guard let backgroundModes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String],
              backgroundModes.contains("location") else {
            print("MJLocationManager: 未配置后台定位模式，请在Info.plist中添加UIBackgroundModes并包含location")
            return
        }
        
        if #available(iOS 9.0, *) {
            // iOS 9+ 需要检查授权状态后再设置
            let status = currentAuthorizationStatus
            if status == .authorizedAlways {
                enableBackgroundLocationUpdates()
            }
        }
    }
    
    @available(iOS 9.0, *)
    private func enableBackgroundLocationUpdates() {
        guard !hasConfiguredBackgroundUpdates else { return }
        
        // 检查设备是否支持后台定位
        if CLLocationManager.locationServicesEnabled() {
            // 设置后台定位属性
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            hasConfiguredBackgroundUpdates = true
            print("MJLocationManager: 后台定位已启用")
        }
    }
    
    @available(iOS 9.0, *)
    private func disableBackgroundLocationUpdates() {
        guard hasConfiguredBackgroundUpdates else { return }
        
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = true
        hasConfiguredBackgroundUpdates = false
        print("MJLocationManager: 后台定位已禁用")
    }
    
    // MARK: - 获取定位
    /// 请求最新定位
    public func startRequestLocation(locationBlock: ((_ locationInfo: MJLocationInfo) -> Void)? = nil,
                                     failureBlock: (() -> Void)?) {
        self.locationBlock = locationBlock
        self.failureBlock = failureBlock
        
        // 确保在主线程处理UI相关操作
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 检查定位服务是否可用
            guard CLLocationManager.locationServicesEnabled() else {
                print("MJLocationManager: 定位服务不可用")
                failureBlock?()
                return
            }
            
            MJAuthorization.requestAuth(type: .locationWhenInUse) { [weak self] in
                // 开始定位
                self?.startUpdatingLocation()
            }
            
        }
    }
    
    private func startUpdatingLocation() {
        // 开始定位前检查授权状态
        let status = currentAuthorizationStatus
        guard status == .authorizedAlways || status == .authorizedWhenInUse else {
            print("MJLocationManager: 没有定位权限")
            failureBlock?()
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    /// 停止定位
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        
        if #available(iOS 9.0, *) {
            // 停止定位后可以禁用后台定位
            disableBackgroundLocationUpdates()
        }
    }
    
    /// 反地理编码
    public func getLocationWithString(_ value: String,
                                      locationBlock: ((_ list: [MJLocationInfo]) -> Void)? = nil,
                                      failureBlock: (() -> Void)?) {
        geocoder.geocodeAddressString(value) { placemarks, error in
            if let error = error {
                print("MJLocationManager: 地理编码失败 - \(error.localizedDescription)")
                failureBlock?()
                return
            }
            
            guard let allMark = placemarks, !allMark.isEmpty else {
                failureBlock?()
                return
            }
            
            // 反地理编码成功
            var modelList: [MJLocationInfo] = []
            var addressSet = Set<String>()
            
            for mark in allMark {
                /*
                 name:Optional("宝安大道6373号")
                 thoroughfare:Optional("宝安大道")
                 subThoroughfare:Optional("6373号")
                 locality:Optional("深圳市")
                 subLocality:Optional("宝安区")
                 administrativeArea:Optional("广东省")
                 subAdministrativeArea:nil
                 postalCode:nil
                 isoCountryCode:Optional("CN")
                 country:Optional("中国")
                 inlandWater:nil
                 ocean:nil
                 areasOfInterest:Optional(["卓越时代创新园"])
                 */
                let province: String = mark.administrativeArea ?? ""
                let city: String = mark.locality ?? ""
                
                var subLocality: String = mark.subLocality ?? ""
                var name: String = mark.name ?? ""
                
                let addressStr = province + city
                var detailedAddress = province + city
                
                // 清理重复的行政区划信息
                if !subLocality.isEmpty {
                    subLocality = subLocality.replacingOccurrences(of: province, with: "")
                    subLocality = subLocality.replacingOccurrences(of: city, with: "")
                    detailedAddress.append(subLocality)
                }
                
                if !name.isEmpty {
                    name = name.replacingOccurrences(of: province, with: "")
                    name = name.replacingOccurrences(of: city, with: "")
                    name = name.replacingOccurrences(of: subLocality, with: "")
                    detailedAddress.append(name)
                }
                
                // longitude latitude
                let longitude = mark.location?.coordinate.longitude ?? -1
                let latitude = mark.location?.coordinate.latitude ?? -1
                
                // 使用Set去重
                if !addressSet.contains(addressStr) {
                    addressSet.insert(addressStr)
                    
                    var model = MJLocationInfo()
                    model.longitude = longitude
                    model.latitude = latitude
                    model.address = addressStr
                    model.detailedAddress = detailedAddress
                    
                    modelList.append(model)
                }
            }
            
            locationBlock?(modelList)
        }
    }
    
    /// 反向地理编码（通过坐标获取地址）
    public func getAddressWithLocation(latitude: Double,
                                       longitude: Double,
                                       completion: @escaping (MJLocationInfo?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("MJLocationManager: 反向地理编码失败 - \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let mark = placemarks?.first else {
                completion(nil)
                return
            }
            
            let province: String = mark.administrativeArea ?? ""
            let city: String = mark.locality ?? ""
            let subLocality: String = mark.subLocality ?? ""
            let name: String = mark.name ?? ""
            
            let addressStr = province + city
            let detailedAddress = province + city + subLocality + name
            
            var model = MJLocationInfo()
            model.longitude = longitude
            model.latitude = latitude
            model.address = addressStr
            model.detailedAddress = detailedAddress
            
            completion(model)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MJLocationManager: CLLocationManagerDelegate {
    
    /// 定位改变
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let curLocation = locations.first else { return }
        
        let longitude = curLocation.coordinate.longitude
        let latitude = curLocation.coordinate.latitude
        
        // 反向地理编码获取地址
        geocoder.reverseGeocodeLocation(curLocation) { [weak self] (placemarks, error) in
            if let error = error {
                print("MJLocationManager: 反向地理编码失败 - \(error.localizedDescription)")
                return
            }
            
            // 反地理编码成功
            guard let allMark = placemarks, !allMark.isEmpty else { return }
            
            let mark = allMark.first!
            let province: String = mark.administrativeArea ?? ""
            let city: String = mark.locality ?? ""
            let addressStr = province + city
            
            // 创建位置信息模型
            var model = MJLocationInfo()
            model.longitude = longitude
            model.latitude = latitude
            model.address = addressStr
            
            // 构建详细地址
            let subLocality: String = mark.subLocality ?? ""
            let name: String = mark.name ?? ""
            model.detailedAddress = province + city + subLocality + name
            
            // 返回结果
            DispatchQueue.main.async {
                self?.locationBlock?(model)
            }
            
            // 停止定位更新
            self?.stopUpdatingLocation()
        }
    }
    
    /// 授权状态变更 (iOS 14+)
    @available(iOS 14.0, *)
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationStatus(manager.authorizationStatus)
    }
    
    /// 授权状态变更 (iOS 14以下)
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if #available(iOS 14.0, *) {
            // 使用新的API，这个方法不会被调用
        } else {
            handleAuthorizationStatus(status)
        }
    }
    
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("MJLocationManager: 定位未授权")
        case .restricted:
            print("MJLocationManager: 定位受限")
            failureBlock?()
        case .denied:
            print("MJLocationManager: 定位被拒绝")
            failureBlock?()
        case .authorizedAlways:
            print("MJLocationManager: 获得始终定位权限")
            if #available(iOS 9.0, *) {
                enableBackgroundLocationUpdates()
            }
            // 如果有等待的定位请求，继续执行
            if locationBlock != nil {
                startUpdatingLocation()
            }
        case .authorizedWhenInUse:
            print("MJLocationManager: 获得使用时定位权限")
            if #available(iOS 9.0, *) {
                // 使用时定位权限下，禁用后台定位
                disableBackgroundLocationUpdates()
            }
            // 如果有等待的定位请求，继续执行
            if locationBlock != nil {
                startUpdatingLocation()
            }
        @unknown default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("MJLocationManager: 定位失败！Error:\(error.localizedDescription)")
        
        // 根据错误类型处理
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                print("MJLocationManager: 用户拒绝定位权限")
            case .locationUnknown:
                print("MJLocationManager: 位置未知")
            case .network:
                print("MJLocationManager: 网络问题")
            default:
                print("MJLocationManager: 其他定位错误")
            }
        }
        
        locationManager.stopUpdatingLocation()
        
        DispatchQueue.main.async { [weak self] in
            self?.failureBlock?()
        }
    }
}
