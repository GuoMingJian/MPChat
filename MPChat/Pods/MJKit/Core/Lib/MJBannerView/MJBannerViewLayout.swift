//
//  MJBannerViewLayout.swift
//  MJKit
//
//  Created by 郭明健 on 2026/1/21.
//

import UIKit

public enum MJBannerViewLayoutType: UInt {
    case normal
    case linear
    case coverflow
}

public protocol MJBannerViewLayoutDelegate: AnyObject {
    // initialize layout attributes
    func bannerViewTransformLayout(_ bannerViewTransformLayout: MJBannerViewLayout, initializeTransformAttributes attributes: UICollectionViewLayoutAttributes)
    
    // apply layout attributes
    func bannerViewTransformLayout(_ bannerViewTransformLayout: MJBannerViewLayout, applyTransformToAttributes attributes: UICollectionViewLayoutAttributes)
}

/// 布局配置类
public class MJLayout: NSObject {
    
    // MARK: - Public Properties
    
    public var itemSize: CGSize = .zero
    public var itemSpacing: CGFloat = 0
    public var sectionInset: UIEdgeInsets = .zero
    
    public var layoutType: MJBannerViewLayoutType = .normal
    
    public var minimumScale: CGFloat = 0.8  // scale default 0.8
    public var minimumAlpha: CGFloat = 1.0  // alpha default 1.0
    public var maximumAngle: CGFloat = 0.2  // angle is % default 0.2
    
    public var isInfiniteLoop: Bool = false  // infinite scroll
    public var rateOfChange: CGFloat = 0.4   // scale and angle change rate
    public var adjustSpacingWhenScroling: Bool = true
    
    /**
     pageView cell item vertical centering
     */
    public var itemVerticalCenter: Bool = true
    
    /**
     first and last item horizontal center, when isInfiniteLoop is NO
     */
    public var itemHorizontalCenter: Bool = false
    
    // MARK: - Computed Properties
    
    public var onlyOneSectionInset: UIEdgeInsets {
        guard let pageView = pageView else { return sectionInset }
        
        let leftSpace = !isInfiniteLoop && itemHorizontalCenter ?
            (pageView.frame.width - itemSize.width) / 2 : sectionInset.left
        let rightSpace = !isInfiniteLoop && itemHorizontalCenter ?
            (pageView.frame.width - itemSize.width) / 2 : sectionInset.right
        
        if itemVerticalCenter {
            let verticalSpace = (pageView.frame.height - itemSize.height) / 2
            return UIEdgeInsets(top: verticalSpace, left: leftSpace, bottom: verticalSpace, right: rightSpace)
        }
        return UIEdgeInsets(top: sectionInset.top, left: leftSpace, bottom: sectionInset.bottom, right: rightSpace)
    }
    
    public var firstSectionInset: UIEdgeInsets {
        guard let pageView = pageView else { return sectionInset }
        
        if itemVerticalCenter {
            let verticalSpace = (pageView.frame.height - itemSize.height) / 2
            return UIEdgeInsets(top: verticalSpace, left: sectionInset.left, bottom: verticalSpace, right: itemSpacing)
        }
        return UIEdgeInsets(top: sectionInset.top, left: sectionInset.left, bottom: sectionInset.bottom, right: itemSpacing)
    }
    
    public var lastSectionInset: UIEdgeInsets {
        guard let pageView = pageView else { return sectionInset }
        
        if itemVerticalCenter {
            let verticalSpace = (pageView.frame.height - itemSize.height) / 2
            return UIEdgeInsets(top: verticalSpace, left: 0, bottom: verticalSpace, right: sectionInset.right)
        }
        return UIEdgeInsets(top: sectionInset.top, left: 0, bottom: sectionInset.bottom, right: sectionInset.right)
    }
    
    public var middleSectionInset: UIEdgeInsets {
        guard let pageView = pageView else { return sectionInset }
        
        if itemVerticalCenter {
            let verticalSpace = (pageView.frame.height - itemSize.height) / 2
            return UIEdgeInsets(top: verticalSpace, left: 0, bottom: verticalSpace, right: itemSpacing)
        }
        return sectionInset
    }
    
    // MARK: - Internal Properties
    
    weak var pageView: UIView?
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        configureDefaultValues()
    }
    
    private func configureDefaultValues() {
        itemVerticalCenter = true
        minimumScale = 0.8
        minimumAlpha = 1.0
        maximumAngle = 0.2
        rateOfChange = 0.4
        adjustSpacingWhenScroling = true
    }
}

// MARK: - Private Enums

private enum MJTransformLayoutItemDirection {
    case left
    case center
    case right
}

// MARK: - UICollectionViewFlowLayout Subclass

/// 自定义布局类
public class MJBannerViewLayout: UICollectionViewFlowLayout {
    
    // MARK: - Properties
    
    public var layout: MJLayout? {
        didSet {
            guard let layout = layout else { return }
            layout.pageView = collectionView
            updateLayoutProperties(layout)
        }
    }
    
    public weak var delegate: MJBannerViewLayoutDelegate?
    
    // MARK: - Override Properties
    
    public override var itemSize: CGSize {
        get {
            guard let layout = layout else { return super.itemSize }
            return layout.itemSize
        }
        set {
            super.itemSize = newValue
        }
    }
    
    public override var minimumLineSpacing: CGFloat {
        get {
            guard let layout = layout else { return super.minimumLineSpacing }
            return layout.itemSpacing
        }
        set {
            super.minimumLineSpacing = newValue
        }
    }
    
    public override var minimumInteritemSpacing: CGFloat {
        get {
            guard let layout = layout else { return super.minimumInteritemSpacing }
            return layout.itemSpacing
        }
        set {
            super.minimumInteritemSpacing = newValue
        }
    }
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        configureLayout()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayout()
    }
    
    private func configureLayout() {
        scrollDirection = .horizontal
    }
    
    // MARK: - Layout Methods
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let layout = layout else { return super.shouldInvalidateLayout(forBoundsChange: newBounds) }
        return layout.layoutType == .normal ? super.shouldInvalidateLayout(forBoundsChange: newBounds) : true
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let layout = layout else { return super.layoutAttributesForElements(in: rect) }
        
        if shouldApplyTransform(layoutType: layout.layoutType) {
            return applyTransformToAttributes(in: rect, layoutType: layout.layoutType)
        }
        
        return super.layoutAttributesForElements(in: rect)
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        guard let layout = layout else { return attributes }
        
        initializeTransformAttributesIfNeeded(attributes, layoutType: layout.layoutType)
        return attributes
    }
    
    // MARK: - Private Methods
    
    private func updateLayoutProperties(_ layout: MJLayout) {
        itemSize = layout.itemSize
        minimumInteritemSpacing = layout.itemSpacing
        minimumLineSpacing = layout.itemSpacing
    }
    
    private func shouldApplyTransform(layoutType: MJBannerViewLayoutType) -> Bool {
        return delegate?.bannerViewTransformLayout(_:applyTransformToAttributes:) != nil || layoutType != .normal
    }
    
    private func applyTransformToAttributes(in rect: CGRect, layoutType: MJBannerViewLayoutType) -> [UICollectionViewLayoutAttributes]? {
        guard let originalAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        let attributesArray = originalAttributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
        
        guard let collectionView = collectionView else { return attributesArray }
        let visibleRect = CGRect(origin: collectionView.contentOffset,
                                size: collectionView.bounds.size)
        
        for attributes in attributesArray {
            guard visibleRect.intersects(attributes.frame) else { continue }
            
            if let delegate = delegate {
                delegate.bannerViewTransformLayout(self, applyTransformToAttributes: attributes)
            } else {
                applyTransform(to: attributes, layoutType: layoutType)
            }
        }
        
        return attributesArray
    }
    
    private func initializeTransformAttributesIfNeeded(_ attributes: UICollectionViewLayoutAttributes, layoutType: MJBannerViewLayoutType) {
        if let delegate = delegate {
            delegate.bannerViewTransformLayout(self, initializeTransformAttributes: attributes)
        } else if layoutType != .normal {
            initializeTransformAttributes(attributes, layoutType: layoutType)
        }
    }
    
    private func direction(withCenterX centerX: CGFloat) -> MJTransformLayoutItemDirection {
        guard let collectionView = collectionView else { return .right }
        
        let contentCenterX = collectionView.contentOffset.x + collectionView.frame.width / 2
        let diff = centerX - contentCenterX
        
        if abs(diff) < 0.5 {
            return .center
        }
        return diff < 0 ? .left : .right
    }
    
    private func initializeTransformAttributes(_ attributes: UICollectionViewLayoutAttributes, layoutType: MJBannerViewLayoutType) {
        guard let layout = layout else { return }
        
        switch layoutType {
        case .linear:
            applyLinearTransform(to: attributes, scale: layout.minimumScale,
                                alpha: layout.minimumAlpha, layout: layout)
        case .coverflow:
            applyCoverflowTransform(to: attributes, angle: layout.maximumAngle,
                                   alpha: layout.minimumAlpha, layout: layout)
        case .normal:
            break
        }
    }
    
    private func applyTransform(to attributes: UICollectionViewLayoutAttributes, layoutType: MJBannerViewLayoutType) {
        guard let layout = layout else { return }
        
        switch layoutType {
        case .linear:
            applyLinearTransform(to: attributes, layout: layout)
        case .coverflow:
            applyCoverflowTransform(to: attributes, layout: layout)
        case .normal:
            break
        }
    }
    
    // MARK: - Linear Transform
    
    private func applyLinearTransform(to attributes: UICollectionViewLayoutAttributes, layout: MJLayout) {
        guard let collectionView = collectionView else { return }
        
        let collectionViewWidth = collectionView.frame.width
        guard collectionViewWidth > 0 else { return }
        
        let centerX = collectionView.contentOffset.x + collectionViewWidth / 2
        let delta = abs(attributes.center.x - centerX)
        let scale = max(1 - delta / collectionViewWidth * layout.rateOfChange, layout.minimumScale)
        let alpha = max(1 - delta / collectionViewWidth, layout.minimumAlpha)
        
        applyLinearTransform(to: attributes, scale: scale, alpha: alpha, layout: layout)
    }
    
    private func applyLinearTransform(to attributes: UICollectionViewLayoutAttributes,
                                     scale: CGFloat, alpha: CGFloat, layout: MJLayout) {
        var transform = CGAffineTransform(scaleX: scale, y: scale)
        
        if layout.adjustSpacingWhenScroling {
            let direction = direction(withCenterX: attributes.center.x)
            
            switch direction {
            case .center:
                transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                attributes.transform = transform
                attributes.alpha = 1.0
                return
            case .left:
                let translate = 1.15 * attributes.size.width * (1 - scale) / 2
                transform = transform.translatedBy(x: translate, y: 0)
            case .right:
                let translate = -1.15 * attributes.size.width * (1 - scale) / 2
                transform = transform.translatedBy(x: translate, y: 0)
            }
        }
        
        attributes.transform = transform
        attributes.alpha = alpha
    }
    
    // MARK: - Coverflow Transform
    
    private func applyCoverflowTransform(to attributes: UICollectionViewLayoutAttributes, layout: MJLayout) {
        guard let collectionView = collectionView else { return }
        
        let collectionViewWidth = collectionView.frame.width
        guard collectionViewWidth > 0 else { return }
        
        let centerX = collectionView.contentOffset.x + collectionViewWidth / 2
        let delta = abs(attributes.center.x - centerX)
        let angle = min(delta / collectionViewWidth * (1 - layout.rateOfChange), layout.maximumAngle)
        let alpha = max(1 - delta / collectionViewWidth, layout.minimumAlpha)
        
        applyCoverflowTransform(to: attributes, angle: angle, alpha: alpha, layout: layout)
    }
    
    private func applyCoverflowTransform(to attributes: UICollectionViewLayoutAttributes,
                                        angle: CGFloat, alpha: CGFloat, layout: MJLayout) {
        let direction = direction(withCenterX: attributes.center.x)
        var transform3D = CATransform3DIdentity
        transform3D.m34 = -0.002
        
        switch direction {
        case .center:
            // center
            attributes.transform3D = transform3D
            attributes.alpha = 1.0
            return
        case .left:
            let translate = (1 - cos(angle * 1.2 * .pi)) * attributes.size.width
            transform3D = CATransform3DRotate(transform3D, .pi * angle, 0, 1, 0)
            if layout.adjustSpacingWhenScroling {
                transform3D = CATransform3DTranslate(transform3D, translate, 0, 0)
            }
        case .right:
            let translate = -(1 - cos(angle * 1.2 * .pi)) * attributes.size.width
            transform3D = CATransform3DRotate(transform3D, .pi * -angle, 0, 1, 0)
            if layout.adjustSpacingWhenScroling {
                transform3D = CATransform3DTranslate(transform3D, translate, 0, 0)
            }
        }
        
        attributes.transform3D = transform3D
        attributes.alpha = alpha
    }
}
