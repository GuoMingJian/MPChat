//
//  MJBannerViewPageControl.swift
//  MJKit
//
//  Created by 郭明健 on 2026/1/21.
//

import UIKit

public class MJBannerViewPageControl: UIControl {
    
    // MARK: - Public Properties
    
    public var numberOfPages: Int = 0 {
        didSet {
            guard numberOfPages != oldValue else { return }
            if currentPage >= numberOfPages {
                currentPage = 0
            }
            updateIndicatorViews()
            if !indicatorViews.isEmpty {
                setNeedsLayout()
            }
        }
    }
    
    public var currentPage: Int = 0 {
        didSet {
            guard currentPage != oldValue,
                  indicatorViews.count > currentPage else { return }
            _currentPage = currentPage
            
            // 添加平滑动画
            if !currentPageIndicatorSize.equalTo(pageIndicatorSize) {
                UIView.animate(withDuration: animateDuring, delay: 0, options: .curveEaseInOut) {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                }
            } else {
                setNeedsLayout()
            }
            updateIndicatorViewsBehavior()
            if isUserInteractionEnabled {
                sendActions(for: .valueChanged)
            }
        }
    }
    
    public var hidesForSinglePage: Bool = false
    
    public var pageIndicatorSpaing: CGFloat = 10.0 {
        didSet {
            if !indicatorViews.isEmpty {
                setNeedsLayout()
            }
        }
    }
    
    public var contentInset: UIEdgeInsets = .zero
    public private(set) var contentSize: CGSize = .zero
    
    public var pageIndicatorTintColor: UIColor? = UIColor(red: 128/255.0, green: 128/255.0, blue: 128/255.0, alpha: 1.0) {
        didSet {
            updateIndicatorViewsBehavior()
        }
    }
    
    public var currentPageIndicatorTintColor: UIColor? = .white {
        didSet {
            updateIndicatorViewsBehavior()
        }
    }
    
    public var pageIndicatorImage: UIImage? {
        didSet {
            updateIndicatorViewsBehavior()
        }
    }
    
    public var currentPageIndicatorImage: UIImage? {
        didSet {
            updateIndicatorViewsBehavior()
        }
    }
    
    public var indicatorImageContentMode: UIView.ContentMode = .center
    
    public var pageIndicatorSize: CGSize = CGSize(width: 6, height: 6) {
        didSet {
            guard !pageIndicatorSize.equalTo(oldValue) else { return }
            if currentPageIndicatorSize.equalTo(.zero) ||
                (currentPageIndicatorSize.width < pageIndicatorSize.width &&
                 currentPageIndicatorSize.height < pageIndicatorSize.height) {
                currentPageIndicatorSize = pageIndicatorSize
            }
            if !indicatorViews.isEmpty {
                setNeedsLayout()
            }
        }
    }
    
    public var currentPageIndicatorSize: CGSize = CGSize(width: 16, height: 6) {
        didSet {
            guard !currentPageIndicatorSize.equalTo(oldValue) else { return }
            if !indicatorViews.isEmpty {
                setNeedsLayout()
            }
        }
    }
    
    public var animateDuring: TimeInterval = 0.3
    
    // MARK: - Private Properties
    
    private var _currentPage: Int = 0
    private var indicatorViews: [UIImageView] = []
    private var forceUpdate: Bool = false
    private var oldCurrentPage: Int = -1
    
    // MARK: - Life Cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configurePropertys()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurePropertys()
    }
    
    private func configurePropertys() {
        isUserInteractionEnabled = false
        forceUpdate = false
        animateDuring = 0.3
        pageIndicatorSpaing = 10.0
        indicatorImageContentMode = .center
        pageIndicatorSize = CGSize(width: 6, height: 6)
        currentPageIndicatorSize = CGSize(width: 16, height: 6)
        pageIndicatorTintColor = UIColor(red: 128/255.0, green: 128/255.0, blue: 128/255.0, alpha: 1.0)
        currentPageIndicatorTintColor = .white
        oldCurrentPage = -1
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil {
            forceUpdate = true
            updateIndicatorViews()
            forceUpdate = false
        }
    }
    
    // MARK: - Public Methods
    
    public func setCurrentPage(_ currentPage: Int, animate: Bool) {
        if animate {
            UIView.animate(withDuration: animateDuring, delay: 0, options: .curveEaseInOut) {
                self.currentPage = currentPage
            }
        } else {
            self.currentPage = currentPage
        }
    }
    
    // MARK: - Private Methods
    
    private func updateIndicatorViews() {
        guard superview != nil || forceUpdate else { return }
        
        if indicatorViews.count == numberOfPages {
            updateIndicatorViewsBehavior()
            return
        }
        
        var tempIndicatorViews = indicatorViews
        
        if tempIndicatorViews.count < numberOfPages {
            for _ in tempIndicatorViews.count..<numberOfPages {
                let indicatorView = UIImageView()
                indicatorView.contentMode = indicatorImageContentMode
                addSubview(indicatorView)
                tempIndicatorViews.append(indicatorView)
            }
        } else if tempIndicatorViews.count > numberOfPages {
            for idx in (numberOfPages..<tempIndicatorViews.count).reversed() {
                let indicatorView = tempIndicatorViews[idx]
                indicatorView.removeFromSuperview()
                tempIndicatorViews.remove(at: idx)
            }
        }
        
        indicatorViews = tempIndicatorViews
        updateIndicatorViewsBehavior()
        
        // Update content size
        let width = CGFloat(indicatorViews.count - 1) * (pageIndicatorSize.width + pageIndicatorSpaing) +
        pageIndicatorSize.width + contentInset.left + contentInset.right
        let height = currentPageIndicatorSize.height + contentInset.top + contentInset.bottom
        contentSize = CGSize(width: width, height: height)
    }
    
    private func updateIndicatorViewsBehavior() {
        guard !indicatorViews.isEmpty,
              (superview != nil || forceUpdate) else { return }
        
        if hidesForSinglePage && indicatorViews.count == 1 {
            indicatorViews.last?.isHidden = true
            return
        }
        
        for (index, indicatorView) in indicatorViews.enumerated() {
            if pageIndicatorImage != nil {
                indicatorView.contentMode = indicatorImageContentMode
                indicatorView.image = currentPage == index ? currentPageIndicatorImage : pageIndicatorImage
                indicatorView.layer.cornerRadius = 0
            } else {
                indicatorView.image = nil
                
                // 添加颜色过渡动画
                UIView.animate(withDuration: animateDuring) {
                    indicatorView.backgroundColor = self.currentPage == index ?
                    self.currentPageIndicatorTintColor : self.pageIndicatorTintColor
                }
                
                // 计算圆角半径
                let targetCornerRadius = self.currentPage == index ?
                self.currentPageIndicatorSize.height / 2 :
                self.pageIndicatorSize.height / 2
                
                // 添加圆角半径动画
                let animation = CABasicAnimation(keyPath: "cornerRadius")
                animation.fromValue = indicatorView.layer.cornerRadius
                animation.toValue = targetCornerRadius
                animation.duration = animateDuring
                indicatorView.layer.add(animation, forKey: "cornerRadius")
                indicatorView.layer.cornerRadius = targetCornerRadius
            }
            indicatorView.isHidden = false
        }
    }
    
    private func layoutIndicatorViews() {
        guard !indicatorViews.isEmpty else { return }
        
        // 保存旧的当前页码
        let oldPage = oldCurrentPage
        oldCurrentPage = currentPage
        
        var originX: CGFloat = 0
        var centerY: CGFloat = 0
        var currentPageIndicatorSpaing = pageIndicatorSpaing
        
        // Calculate horizontal position
        switch contentHorizontalAlignment {
        case .center:
            // ignore contentInset
            originX = (bounds.width -
                       CGFloat(indicatorViews.count - 1) * (pageIndicatorSize.width + pageIndicatorSpaing) -
                       currentPageIndicatorSize.width) / 2
        case .left:
            originX = contentInset.left
        case .right:
            originX = bounds.width -
            (CGFloat(indicatorViews.count - 1) * (pageIndicatorSize.width + pageIndicatorSpaing) +
             currentPageIndicatorSize.width) -
            contentInset.right
        case .fill:
            originX = contentInset.left
            if indicatorViews.count > 1 {
                currentPageIndicatorSpaing = (bounds.width - contentInset.left - contentInset.right -
                                              pageIndicatorSize.width -
                                              CGFloat(indicatorViews.count - 1) * pageIndicatorSize.width) /
                CGFloat(indicatorViews.count - 1)
            }
        default:
            break
        }
        
        // Calculate vertical position
        switch contentVerticalAlignment {
        case .center:
            centerY = bounds.height / 2
        case .top:
            centerY = contentInset.top + currentPageIndicatorSize.height / 2
        case .bottom:
            centerY = bounds.height - currentPageIndicatorSize.height / 2 - contentInset.bottom
        case .fill:
            centerY = (bounds.height - contentInset.top - contentInset.bottom) / 2 + contentInset.top
        default:
            break
        }
        
        // Layout indicator views with animation
        for (index, indicatorView) in indicatorViews.enumerated() {
            let size = index == currentPage ? currentPageIndicatorSize : pageIndicatorSize
            
            // 如果是当前页从其他页变化而来，或者当前页变为其他页，添加动画
            let shouldAnimate = (oldPage != -1 && (index == currentPage || index == oldPage)) &&
                !currentPageIndicatorSize.equalTo(pageIndicatorSize)
            
            if shouldAnimate {
                UIView.animate(withDuration: animateDuring, delay: 0, options: .curveEaseInOut) {
                    indicatorView.frame = CGRect(x: originX,
                                                 y: centerY - size.height / 2,
                                                 width: size.width,
                                                 height: size.height)
                }
            } else {
                indicatorView.frame = CGRect(x: originX,
                                             y: centerY - size.height / 2,
                                             width: size.width,
                                             height: size.height)
            }
            
            originX += size.width + currentPageIndicatorSpaing
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutIndicatorViews()
    }
    
    // MARK: - Override UIControl Properties
    
    public override var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
        didSet {
            if !indicatorViews.isEmpty {
                setNeedsLayout()
            }
        }
    }
    
    public override var contentVerticalAlignment: UIControl.ContentVerticalAlignment {
        didSet {
            if !indicatorViews.isEmpty {
                setNeedsLayout()
            }
        }
    }
}
