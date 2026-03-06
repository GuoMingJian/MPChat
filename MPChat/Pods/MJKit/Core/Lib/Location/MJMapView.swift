//
//  MJMapView.swift
//
//  Created by GuoMingJian on 2025/6/29.
//

import UIKit
import MapKit

/*
 let mapView: MJMapView = MJMapView()
 mapView.translatesAutoresizingMaskIntoConstraints = false
 view.addSubview(mapView)
 NSLayoutConstraint.activate([
 mapView.topAnchor.constraint(equalTo: mySwitch.bottomAnchor, constant: 30),
 mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
 mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
 mapView.heightAnchor.constraint(equalToConstant: 300)
 ])
 mapView.updateInfo(address: "广东省深圳市南山区高新南一道8号", updatTime: "2025-07-18 23:00:04", longitude: 113.96, latitude: 22.54)
 */

public class MJMapView: UIView {
    private var mapView: MKMapView!
    // 保存地标点
    private var firstAnnotation = MKPointAnnotation()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupMapView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMapView() {
        mapView = MKMapView(frame: self.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        addSubview(mapView)
    }
    
    // MARK: - public
    // 地址
    public var address: String = ""
    // 更新时间
    public var updatTime: String = ""
    // 经度
    public var longitude: Double = -1
    // 纬度
    public var latitude: Double = -1
    
    // 点击地图气泡Block
    public var onClickMapBlock: (() -> Void)?
    
    public func updateInfo(address: String,
                           updatTime: String,
                           longitude: Double,
                           latitude: Double) {
        self.layoutIfNeeded()
        self.setNeedsLayout()
        //
        self.address = address
        self.updatTime = updatTime
        self.longitude = longitude
        self.latitude = latitude
        
        mapView.removeAnnotation(firstAnnotation)
        
        // 更新地图中心
        let location = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        // 添加标注
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
        self.firstAnnotation = annotation
        // 默认选中气泡
        mapView.selectAnnotation(self.firstAnnotation, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension MJMapView: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView,
                        viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "customAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            // 自定义标注
            annotationView?.image = "mj_map_address".mj_Image()
        } else {
            annotationView?.annotation = annotation
        }
        // 自定义气泡
        let customBubbleView = createCustomBubbleView(for: annotation)
        annotationView?.detailCalloutAccessoryView = customBubbleView
        annotationView?.detailCalloutAccessoryView?.backgroundColor = .clear
        return annotationView
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.selectAnnotation(self.firstAnnotation, animated: false)
    }
    
    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        mapView.selectAnnotation(self.firstAnnotation, animated: false)
    }
    
    // MARK: -
    private func createCustomBubbleView(for annotation: MKAnnotation) -> UIView {
        let bubbleView = UIView()
        bubbleView.setCornerRadius(radius: 10)
        // 地址
        let addressLabel = UILabel()
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        var addressStr = address
        if addressStr.count == 0 {
            addressStr = "--"
        }
        addressLabel.text = addressStr
        addressLabel.font = UIFont.SFP_Regular(fontSize: 11)
        addressLabel.numberOfLines = 0
        // 时间
        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = updatTime
        timeLabel.font = UIFont.SFP_Regular(fontSize: 10)
        timeLabel.numberOfLines = 0
        // Icon
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = "mj_map_go".mj_Image()
        // RTL
        //        if LanguageManager.shared.isNeedSwitchLeftAndRight() {
        //            imageView.image = imageView.image?.flippedOrientationImage()
        //        }
        
        bubbleView.addSubview(addressLabel)
        bubbleView.addSubview(timeLabel)
        bubbleView.addSubview(imageView)
        
        let maxLabelWidth: CGFloat = MJ.kScreenWidth - 50 * 2
        
        NSLayoutConstraint.activate([
            addressLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            addressLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 3),
            addressLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            addressLabel.widthAnchor.constraint(lessThanOrEqualToConstant: maxLabelWidth),
            
            timeLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 3),
            timeLabel.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
            
            imageView.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: timeLabel.trailingAnchor, constant: 50),
            imageView.widthAnchor.constraint(equalToConstant: 10),
            imageView.heightAnchor.constraint(equalToConstant: 8),
            imageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor)
        ])
        
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bubbleTapped))
        bubbleView.addGestureRecognizer(tapGesture)
        
        return bubbleView
    }
    
    @objc private func bubbleTapped() {
        onClickMapBlock?()
    }
}
