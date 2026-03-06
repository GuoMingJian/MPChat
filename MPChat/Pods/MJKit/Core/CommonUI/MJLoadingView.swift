//
//  MJLoadingView.swift
//  MJKit
//
//  Created by 郭明健 on 2026/1/29.
//

import UIKit

@objc public enum MJLoadingStatusType: Int {
    case success = 0
    case fail
    
    public func getIconName() -> String {
        switch self {
        case .success:
            return "mj_status_success"
        case .fail:
            return "mj_status_fail"
        }
    }
}

@objcMembers
public class MJLoadingView: UIView {
    private let containerView = UIView()
    private let tipLabel = UILabel()
    private let imageView = UIImageView()
    
    private var isStatusMode = false
    private let statusDismissTime: TimeInterval = 2
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        // 容器视图
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        addSubview(containerView)
        
        // 图片视图
        imageView.image = "mj_loading".mj_Image()
        imageView.contentMode = .scaleAspectFit
        containerView.addSubview(imageView)
        
        // 提示标签
        tipLabel.text = "api_loading".mj_Localized()
        tipLabel.textColor = UIColor.white
        tipLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tipLabel.textAlignment = .center
        tipLabel.numberOfLines = 0
        containerView.addSubview(tipLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 容器视图约束
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 120),
            containerView.heightAnchor.constraint(equalToConstant: 120),
            
            // 图片约束
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            imageView.widthAnchor.constraint(equalToConstant: 36),
            imageView.heightAnchor.constraint(equalToConstant: 36),
            
            // 标签约束
            tipLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            tipLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            tipLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            tipLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
    public func showLoading() {
        imageView.mj_startRotationAnimation()
    }
    
    public func hideLoading() {
        imageView.mj_removeAnimations()
        removeFromSuperview()
    }
    
    public func showStatus(iconName: String, text: String) {
        isStatusMode = true
        imageView.mj_removeAnimations()
        imageView.image = iconName.mj_Image()
        tipLabel.text = text
    }
}

// MARK: - Rotation Animation Extension
public extension UIImageView {
    func mj_startRotationAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 1
        rotation.repeatCount = .infinity
        rotation.isRemovedOnCompletion = false
        layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func mj_removeAnimations() {
        layer.removeAllAnimations()
    }
}

// MARK: - Loading
public extension MJLoadingView {
    /// 显示 Loading页面
    @objc static func show() {
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        // 检查是否已经存在
        if isExist(in: keyWindow) {
            return
        }
        
        let loadingView = MJLoadingView()
        loadingView.frame = keyWindow.bounds
        loadingView.tag = 7777
        keyWindow.addSubview(loadingView)
        
        loadingView.showLoading()
    }
    
    /// 隐藏 Loading页面
    @objc static func hide() {
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        if let loadingView = keyWindow.viewWithTag(7777) as? MJLoadingView {
            loadingView.hideLoading()
        }
    }
    
    /// app 从后台进入前台时，让Loading旋转起来
    @objc static func checkLoading() {
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        if let loadingView = keyWindow.viewWithTag(7777) as? MJLoadingView {
            loadingView.showLoading()
        }
    }
    
    /// 检查是否已存在 LoadingView
    private static func isExist(in view: UIView) -> Bool {
        for subview in view.subviews {
            if subview is MJLoadingView && subview.tag == 7777 {
                return true
            }
        }
        return false
    }
}

// MARK: - 显示状态
public extension MJLoadingView {
    /// 显示状态，成功、失败
    @objc static func showStatus(statusType: MJLoadingStatusType,
                                 text: String,
                                 dismissTime: TimeInterval = 2) {
        showStatus(iconName: statusType.getIconName(),
                   text: text,
                   dismissTime: dismissTime)
    }
    
    /// 显示状态，成功、失败
    @objc static func showStatus(iconName: String,
                                 text: String,
                                 dismissTime: TimeInterval = 2) {
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        // 检查是否已经存在状态视图
        if let existingStatusView = keyWindow.viewWithTag(8888) as? MJLoadingView {
            existingStatusView.removeFromSuperview()
        }
        
        let statusView = MJLoadingView()
        statusView.frame = keyWindow.bounds
        statusView.tag = 8888
        statusView.showStatus(iconName: iconName, text: text)
        keyWindow.addSubview(statusView)
        
        // 自动隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissTime) {
            hideStatus()
        }
    }
    
    /// 隐藏状态
    @objc static func hideStatus() {
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        if let statusView = keyWindow.viewWithTag(8888) as? MJLoadingView {
            statusView.hideLoading()
        }
    }
}

#if canImport(NVActivityIndicatorView)
import NVActivityIndicatorView

public extension MJLoadingView {
    @objc static func showDotLoading(width: CGFloat = 40,
                                     color: UIColor = UIColor.black) {
        hiddenDotLoading()
        
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        let activityIndicatorView = NVActivityIndicatorView(frame: .zero,
                                                            type: .ballSpinFadeLoader,
                                                            color: color,
                                                            padding: nil)
        activityIndicatorView.tag = 9999
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        keyWindow.addSubview(activityIndicatorView)
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: keyWindow.centerYAnchor),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: width),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: width),
        ])
        
        activityIndicatorView.startAnimating()
    }
    
    @objc static func hiddenDotLoading() {
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        if let activityView = keyWindow.viewWithTag(9999) as? NVActivityIndicatorView {
            activityView.stopAnimating()
            activityView.removeFromSuperview()
        }
    }
}
#endif
