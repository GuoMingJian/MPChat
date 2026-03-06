//
//  MJPanView.swift
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit
/**
 使用说明：
 MJPanView是一个用来处理滑动卡片的类，使用的时候自己创建一个类继承于它.
 - 必须设置的是：topMinHeight、topMaxHeight
 - 如果卡片上放了一个 UITableView 或者 UICollectionView.
 需要做的如下:
 1、重写 scrollViewDidToTop() 和 scrollViewDidToBottom() 两个方法
 2、在 UITableView 或者 UICollectionView 的
 scrollViewDidScroll 的方法里面设置
 self.stop_y = scrollView.contentOffset.y
 */

@objcMembers
open class MJPanView: UIView {
    /// 上滑后距离顶部的最小距离(相对父视图来说)
    open var topMinHeight: CGFloat = 0
    /// 上滑后距离顶部的最大距离(相对父视图来说)
    open var topMaxHeight: CGFloat = 0
    /// UITableView 或者 UICollectionView滑动停止的位置
    ///
    /// - Note: 需要在 UITableView 或者 UICollectionView 的- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
    open var stop_y: CGFloat = 0
    /// 回到顶部
    open var didGoTopBlock: (() -> Void)?
    /// 回到底部
    open var didGoBottomBlock: (() -> Void)?
    /// 滑动中
    open var scrollViewDidScrollBlock: ((_ contentOffsetY: CGFloat) -> Void)?
    /// 自定义滑动临界高度
    open var customMiddleHeight: CGFloat?
    /// 最大距离和最小距离之间的距离(用来判断松后后卡片滑动的方向)
    private var middleHeight: CGFloat {
        return (topMinHeight + topMaxHeight) / 2.0
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupPanGesture()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPanGesture()
    }
    
    private func setupPanGesture() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panHandle(_:)))
        panRecognizer.delegate = self
        self.addGestureRecognizer(panRecognizer)
    }
}

// MARK: - 滑动结束调用的方法
extension MJPanView {
    /// 回到顶部
    open func scrollViewDidToTop() {
        // 子类可重写
    }
    
    /// 回到底部
    open func scrollViewDidToBottom() {
        // 子类可重写
    }
}

// MARK: - 滑动相关的处理
extension MJPanView {
    // MARK: - 手势滑动代理
    /// 手势滑动代理
    /// - Parameter pan: 滑动手势
    @objc private func panHandle(_ pan: UIPanGestureRecognizer) {
        // 获取视图偏移量
        let translationPoint = pan.translation(in: self)
        let transY = translationPoint.y
        
        // stop_y是tableview的偏移量，当tableview的偏移量大于0时则不去处理视图滑动的事件
        if self.stop_y > 0 {
            // 将视频偏移量重置为0
            pan.setTranslation(CGPoint(x: 0, y: 0), in: self)
            return
        }
        
        self.frame.origin.y += transY
        
        if self.frame.origin.y < self.topMinHeight {
            self.frame.origin.y = self.topMinHeight
        }
        
        // self.topMaxHeight是视图在底部时距离顶部的距离
        if self.frame.origin.y > self.topMaxHeight {
            self.frame.origin.y = self.topMaxHeight
        }
        
        // 在滑动手势结束时判断滑动视图距离顶部的距离是否超过了屏幕的一半，如果超过了一半就往下滑到底部
        // 如果小于一半就往上滑到顶部
        if pan.state == .ended || pan.state == .cancelled {
            // 滑动速度
            let velocity = pan.velocity(in: self)
            let speed: CGFloat = 350
            if velocity.y < -speed {
                goTop()
                pan.setTranslation(CGPoint(x: 0, y: 0), in: self)
                return
            } else if velocity.y > speed {
                goBottom()
                pan.setTranslation(CGPoint(x: 0, y: 0), in: self)
                return
            }
            
            if self.frame.origin.y >= (customMiddleHeight ?? middleHeight) {
                goBottom()
            } else {
                goTop()
            }
        } else if pan.state == .changed {
            scrollViewDidScrollBlock?(self.frame.origin.y)
        }
        pan.setTranslation(CGPoint(x: 0, y: 0), in: self)
    }
    
    // MARK: 回到顶部
    /// 回到顶部
    @objc open func goTop() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.frame.origin.y = self.topMinHeight
        } completion: { [weak self] finished in
            guard let self = self else { return }
            self.scrollViewDidToTop()
            self.didGoTopBlock?()
        }
    }
    
    // MARK: 回到底部
    /// 回到底部
    @objc open func goBottom() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.frame.origin.y = self.topMaxHeight
        } completion: { [weak self] finished in
            guard let self = self else { return }
            self.scrollViewDidToBottom()
            self.didGoBottomBlock?()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MJPanView: UIGestureRecognizerDelegate {
    /// 同时相应多个手势
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
