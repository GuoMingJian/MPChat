//
//  MJBannerView.swift
//  MJKit
//
//  Created by 郭明健 on 2026/1/21.
//

import UIKit

// MARK: - Type Definitions

/// 索引和分区结构体
public struct MJIndexSection: Equatable {
    public var index: Int = 0
    public var section: Int = 0
    
    public init() {}
    
    public init(index: Int, section: Int) {
        self.index = index
        self.section = section
    }
    
    public static func make(index: Int, section: Int) -> MJIndexSection {
        return MJIndexSection(index: index, section: section)
    }
    
    public static func == (lhs: MJIndexSection, rhs: MJIndexSection) -> Bool {
        return lhs.index == rhs.index && lhs.section == rhs.section
    }
}

/// 滚动方向
public enum MJPagerScrollDirection {
    case left
    case right
}

// MARK: - Protocols

/// BannerView代理协议
public protocol MJBannerViewDelegate: AnyObject {
    func bannerView(_ bannerView: MJBannerView, didScrollFromIndex fromIndex: Int, toIndex: Int)
    func bannerView(_ bannerView: MJBannerView, initializeTransformAttributes attributes: UICollectionViewLayoutAttributes)
    func bannerView(_ bannerView: MJBannerView, applyTransformToAttributes attributes: UICollectionViewLayoutAttributes)
    func bannerViewDidScroll(_ bannerView: MJBannerView)
    func bannerViewWillBeginScrollingAnimation(_ bannerView: MJBannerView)
    func bannerViewWillBeginDragging(_ bannerView: MJBannerView)
    func bannerViewDidEndDragging(_ bannerView: MJBannerView, willDecelerate decelerate: Bool)
    func bannerViewWillBeginDecelerating(_ bannerView: MJBannerView)
    func bannerViewDidEndDecelerating(_ bannerView: MJBannerView)
    func bannerViewDidEndScrollingAnimation(_ bannerView: MJBannerView)
    func bannerView(_ bannerView: MJBannerView, didSelectedItemCell cell: UICollectionViewCell, atIndex index: Int)
    func bannerView(_ bannerView: MJBannerView, didSelectedItemCell cell: UICollectionViewCell, atIndexSection indexSection: MJIndexSection)
}

// 默认空实现
public extension MJBannerViewDelegate {
    func bannerView(_ bannerView: MJBannerView, didScrollFromIndex fromIndex: Int, toIndex: Int) {}
    func bannerView(_ bannerView: MJBannerView, initializeTransformAttributes attributes: UICollectionViewLayoutAttributes) {}
    func bannerView(_ bannerView: MJBannerView, applyTransformToAttributes attributes: UICollectionViewLayoutAttributes) {}
    func bannerViewDidScroll(_ bannerView: MJBannerView) {}
    func bannerViewWillBeginScrollingAnimation(_ bannerView: MJBannerView) {}
    func bannerViewWillBeginDragging(_ bannerView: MJBannerView) {}
    func bannerViewDidEndDragging(_ bannerView: MJBannerView, willDecelerate decelerate: Bool) {}
    func bannerViewWillBeginDecelerating(_ bannerView: MJBannerView) {}
    func bannerViewDidEndDecelerating(_ bannerView: MJBannerView) {}
    func bannerViewDidEndScrollingAnimation(_ bannerView: MJBannerView) {}
    func bannerView(_ bannerView: MJBannerView, didSelectedItemCell cell: UICollectionViewCell, atIndex index: Int) {}
    func bannerView(_ bannerView: MJBannerView, didSelectedItemCell cell: UICollectionViewCell, atIndexSection indexSection: MJIndexSection) {}
}

public protocol MJBannerViewDataSource: AnyObject {
    func numberOfItemsInBannerView(_ bannerView: MJBannerView) -> Int
    func bannerView(_ bannerView: MJBannerView, cellForItemAt index: Int) -> UICollectionViewCell
    func layoutForBannerView(_ bannerView: MJBannerView) -> MJLayout
}

// MARK: - MJBannerView

private let kBannerViewMaxSectionCount = 200
private let kBannerViewMinSectionCount = 18

public class MJBannerView: UIView {
    
    // MARK: - Properties
    
    public weak var delegate: MJBannerViewDelegate?
    public weak var dataSource: MJBannerViewDataSource?
    
    public var autoScrollInterval: TimeInterval = 0 {
        didSet {
            removeTimer()
            if autoScrollInterval > 0 && superview != nil {
                addTimer()
            }
        }
    }
    
    public var isInfiniteLoop: Bool = true
    public var isShowInCenter: Bool = true
    public var reloadDataNeedResetIndex: Bool = true
    
    public private(set) var curIndex: Int = 0
    public var contentOffset: CGPoint {
        return collectionView.contentOffset
    }
    public var tracking: Bool {
        return collectionView.isTracking
    }
    public var dragging: Bool {
        return collectionView.isDragging
    }
    public var decelerating: Bool {
        return collectionView.isDecelerating
    }
    public var backgroundView: UIView? {
        get { return collectionView.backgroundView }
        set { collectionView.backgroundView = newValue }
    }
    public var curIndexCell: UICollectionViewCell? {
        if indexSection.index < 0 || indexSection.section < 0 { return nil }
        let indexPath = IndexPath(item: indexSection.index, section: indexSection.section)
        return collectionView.cellForItem(at: indexPath)
    }
    public var visibleCells: [UICollectionViewCell] {
        return collectionView.visibleCells
    }
    public var visibleIndexs: [Int] {
        return collectionView.indexPathsForVisibleItems.map { $0.item }
    }
    
    // MARK: - Private Properties
    
    private var collectionView: UICollectionView!
    private var layout: MJLayout?
    private var timer: Timer?
    
    private var mj_firstScroll: Bool = true
    private var numberOfItems: Int = 0
    private var dequeueSection: Int = 0
    private var beginDragIndexSection = MJIndexSection()
    private var firstScrollIndex: Int = -1
    public var indexSection = MJIndexSection(index: -1, section: -1)
    
    private var needClearLayout: Bool = false
    private var didReloadData: Bool = false
    private var didLayout: Bool = false
    private var needResetIndex: Bool = false
    
    // MARK: - Life Cycle
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureProperty()
        addCollectionView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configureProperty()
        addCollectionView()
    }
    
    private func configureProperty() {
        needResetIndex = false
        didReloadData = false
        didLayout = false
        autoScrollInterval = 0
        isInfiniteLoop = true
        isShowInCenter = true
        beginDragIndexSection = MJIndexSection(index: 0, section: 0)
        indexSection = MJIndexSection(index: -1, section: -1)
        firstScrollIndex = -1
        mj_firstScroll = true
    }
    
    private func addCollectionView() {
        let collectionViewLayout = MJBannerViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = false
        collectionView.decelerationRate = .normal
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        addSubview(collectionView)
        self.collectionView = collectionView
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let needUpdateLayout = !collectionView.frame.equalTo(self.bounds)
        collectionView.frame = self.bounds
        
        if (indexSection.section < 0 || needUpdateLayout) && (numberOfItems > 0 || didReloadData) {
            didLayout = true
            setNeedUpdateLayout()
        }
    }
    
    deinit {
        (collectionView.collectionViewLayout as? MJBannerViewLayout)?.delegate = nil
        collectionView.delegate = nil
        collectionView.dataSource = nil
        removeTimer()
    }
    
    // MARK: - Timer
    
    private func addTimer() {
        if timer != nil || autoScrollInterval <= 0 {
            return
        }
        
        timer = Timer(timeInterval: autoScrollInterval, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func timerFired() {
        if superview == nil || window == nil || numberOfItems == 0 || self.tracking {
            return
        }
        
        scrollToNearlyIndex(at: .right, animate: true)
    }
    
    // MARK: - Layout Configuration
    
    private var currentLayout: MJLayout {
        if layout == nil {
            layout = dataSource?.layoutForBannerView(self)
            layout?.isInfiniteLoop = isInfiniteLoop
            if let layout = layout, (layout.itemSize.width <= 0 || layout.itemSize.height <= 0) {
                self.layout = nil
            }
        }
        return layout ?? MJLayout()
    }
    
    private func updateLayout() {
        let layout = currentLayout
        layout.isInfiniteLoop = isInfiniteLoop
        if let transformLayout = collectionView.collectionViewLayout as? MJBannerViewLayout {
            transformLayout.layout = layout
        }
    }
    
    private func clearLayout() {
        if needClearLayout {
            layout = nil
            needClearLayout = false
        }
    }
    
    private func setNeedClearLayout() {
        needClearLayout = true
    }
    
    private func setNeedUpdateLayout() {
        if layout == nil {
            return
        }
        clearLayout()
        updateLayout()
        collectionView.collectionViewLayout.invalidateLayout()
        resetBannerView(at: indexSection.index < 0 ? 0 : indexSection.index)
    }
    
    // MARK: - Public Methods
    
    public func reloadData() {
        didReloadData = true
        needResetIndex = true
        setNeedClearLayout()
        clearLayout()
        updateData()
    }
    
    public func updateData() {
        updateLayout()
        numberOfItems = dataSource?.numberOfItemsInBannerView(self) ?? 0
        collectionView.reloadData()
        
        if !didLayout && !collectionView.frame.isEmpty && indexSection.index < 0 {
            didLayout = true
        }
        
        let needResetIndex = self.needResetIndex && reloadDataNeedResetIndex
        self.needResetIndex = false
        
        if needResetIndex {
            removeTimer()
        }
        
        let targetIndex = (indexSection.index < 0 && !collectionView.frame.isEmpty) || needResetIndex ? 0 : indexSection.index
        resetBannerView(at: targetIndex)
        
        if needResetIndex {
            addTimer()
        }
    }
    
    public func scrollToNearlyIndex(at direction: MJPagerScrollDirection, animate: Bool) {
        let indexSection = nearlyIndexPath(at: direction)
        scrollToItem(at: indexSection, animate: animate)
    }
    
    public func scrollToItem(at index: Int, animate: Bool) {
        if !didLayout && didReloadData {
            firstScrollIndex = index
        } else {
            firstScrollIndex = -1
        }
        
        if !isInfiniteLoop {
            scrollToItem(at: MJIndexSection.make(index: index, section: 0), animate: animate)
            return
        }
        
        let section = index >= curIndex ? self.indexSection.section : self.indexSection.section + 1
        scrollToItem(at: MJIndexSection.make(index: index, section: section), animate: animate)
    }
    
    public func scrollToItem(at indexSection: MJIndexSection, animate: Bool) {
        if numberOfItems <= 0 || !isValidIndexSection(indexSection) {
            return
        }
        
        if animate {
            delegate?.bannerViewWillBeginScrollingAnimation(self)
        }
        
        let offset = caculateOffsetX(at: indexSection)
        collectionView.setContentOffset(CGPoint(x: offset, y: collectionView.contentOffset.y), animated: animate)
    }
    
    public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(item: index, section: dequeueSection)
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    // MARK: - Index Calculation
    
    private func isValidIndexSection(_ indexSection: MJIndexSection) -> Bool {
        return indexSection.index >= 0 && indexSection.index < numberOfItems &&
        indexSection.section >= 0 && indexSection.section < kBannerViewMaxSectionCount
    }
    
    private func nearlyIndexPath(at direction: MJPagerScrollDirection) -> MJIndexSection {
        return nearlyIndexPath(for: indexSection, direction: direction)
    }
    
    private func nearlyIndexPath(for indexSection: MJIndexSection, direction: MJPagerScrollDirection) -> MJIndexSection {
        if indexSection.index < 0 || indexSection.index >= numberOfItems {
            return indexSection
        }
        
        if !isInfiniteLoop {
            if direction == .right && indexSection.index == numberOfItems - 1 {
                return autoScrollInterval > 0 ? MJIndexSection.make(index: 0, section: 0) : indexSection
            } else if direction == .right {
                return MJIndexSection.make(index: indexSection.index + 1, section: 0)
            }
            
            if indexSection.index == 0 {
                return autoScrollInterval > 0 ? MJIndexSection.make(index: numberOfItems - 1, section: 0) : indexSection
            }
            return MJIndexSection.make(index: indexSection.index - 1, section: 0)
        }
        
        if direction == .right {
            if indexSection.index < numberOfItems - 1 {
                return MJIndexSection.make(index: indexSection.index + 1, section: indexSection.section)
            }
            if indexSection.section >= kBannerViewMaxSectionCount - 1 {
                return MJIndexSection.make(index: indexSection.index, section: kBannerViewMaxSectionCount - 1)
            }
            return MJIndexSection.make(index: 0, section: indexSection.section + 1)
        }
        
        if indexSection.index > 0 {
            return MJIndexSection.make(index: indexSection.index - 1, section: indexSection.section)
        }
        if indexSection.section <= 0 {
            return MJIndexSection.make(index: indexSection.index, section: 0)
        }
        return MJIndexSection.make(index: numberOfItems - 1, section: indexSection.section - 1)
    }
    
    private func caculateIndexSection(with offsetX: CGFloat) -> MJIndexSection {
        if numberOfItems <= 0 {
            return MJIndexSection.make(index: 0, section: 0)
        }
        
        guard let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return MJIndexSection.make(index: 0, section: 0)
        }
        
        let leftEdge = isInfiniteLoop ? currentLayout.sectionInset.left : currentLayout.onlyOneSectionInset.left
        let width = collectionView.frame.width
        let middleOffset = offsetX + width / 2
        let itemWidth = collectionViewLayout.itemSize.width + collectionViewLayout.minimumInteritemSpacing
        
        var curIndex = 0
        var curSection = 0
        
        if middleOffset - leftEdge >= 0 {
            let itemIndex = Int((middleOffset - leftEdge + collectionViewLayout.minimumInteritemSpacing / 2) / itemWidth)
            let maxItemIndex = numberOfItems * kBannerViewMaxSectionCount - 1
            let safeItemIndex = min(max(itemIndex, 0), maxItemIndex)
            curIndex = safeItemIndex % numberOfItems
            curSection = safeItemIndex / numberOfItems
        }
        
        return MJIndexSection.make(index: curIndex, section: curSection)
    }
    
    private func caculateOffsetX(at indexSection: MJIndexSection) -> CGFloat {
        if numberOfItems == 0 {
            return 0
        }
        
        guard let collectionView = collectionView,
              let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return 0
        }
        
        let edge = isInfiniteLoop ? currentLayout.sectionInset : currentLayout.onlyOneSectionInset
        let leftEdge = edge.left
        let rightEdge = edge.right
        let width = collectionView.frame.width
        let itemWidth = collectionViewLayout.itemSize.width + collectionViewLayout.minimumInteritemSpacing
        
        var offsetX: CGFloat = 0
        
        if !isInfiniteLoop && !currentLayout.itemHorizontalCenter && indexSection.index == numberOfItems - 1 {
            offsetX = leftEdge + itemWidth * CGFloat(indexSection.index + indexSection.section * numberOfItems) -
            (width - itemWidth) - collectionViewLayout.minimumInteritemSpacing + rightEdge
        } else {
            offsetX = leftEdge + itemWidth * CGFloat(indexSection.index + indexSection.section * numberOfItems) -
            collectionViewLayout.minimumInteritemSpacing / 2 - (width - itemWidth) / 2
            
            if !isShowInCenter {
                let a = (width - itemWidth) / 2
                let b = itemWidth - a + collectionViewLayout.minimumInteritemSpacing / 2
                offsetX = offsetX - b
                if mj_firstScroll {
                    offsetX += itemWidth
                    mj_firstScroll = false
                }
            }
        }
        
        return max(offsetX, 0)
    }
    
    private func resetBannerView(at index: Int) {
        var targetIndex = index
        
        if didLayout && firstScrollIndex >= 0 {
            targetIndex = firstScrollIndex
            firstScrollIndex = -1
        }
        
        if targetIndex < 0 {
            return
        }
        
        if targetIndex >= numberOfItems {
            targetIndex = 0
        }
        
        let section = isInfiniteLoop ? kBannerViewMaxSectionCount / 3 : 0
        scrollToItem(at: MJIndexSection.make(index: targetIndex, section: section), animate: false)
        
        if !isInfiniteLoop && indexSection.index < 0 {
            scrollViewDidScroll(collectionView)
        }
    }
    
    private func recycleBannerViewIfNeed() {
        if !isInfiniteLoop {
            return
        }
        
        if indexSection.section > kBannerViewMaxSectionCount - kBannerViewMinSectionCount ||
            indexSection.section < kBannerViewMinSectionCount {
            resetBannerView(at: indexSection.index)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension MJBannerView: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isInfiniteLoop ? kBannerViewMaxSectionCount : 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItems = dataSource?.numberOfItemsInBannerView(self) ?? 0
        return numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        dequeueSection = indexPath.section
        return dataSource?.bannerView(self, cellForItemAt: indexPath.item) ?? UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MJBannerView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if !isInfiniteLoop {
            return currentLayout.onlyOneSectionInset
        }
        
        if section == 0 {
            return currentLayout.firstSectionInset
        } else if section == kBannerViewMaxSectionCount - 1 {
            return currentLayout.lastSectionInset
        }
        return currentLayout.middleSectionInset
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        delegate?.bannerView(self, didSelectedItemCell: cell, atIndex: indexPath.item)
        let indexSection = MJIndexSection.make(index: indexPath.item, section: indexPath.section)
        delegate?.bannerView(self, didSelectedItemCell: cell, atIndexSection: indexSection)
    }
}

// MARK: - UIScrollViewDelegate

extension MJBannerView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !didLayout {
            return
        }
        
        let newIndexSection = caculateIndexSection(with: scrollView.contentOffset.x)
        if numberOfItems <= 0 || !isValidIndexSection(newIndexSection) {
            debugPrint("invalidIndexSection:(\(newIndexSection.index),\(newIndexSection.section))!")
            return
        }
        
        let oldIndexSection = indexSection
        indexSection = newIndexSection
        curIndex = indexSection.index
        
        delegate?.bannerViewDidScroll(self)
        
        if newIndexSection != oldIndexSection {
            delegate?.bannerView(self, didScrollFromIndex: max(oldIndexSection.index, 0), toIndex: indexSection.index)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if autoScrollInterval > 0 {
            removeTimer()
        }
        
        beginDragIndexSection = caculateIndexSection(with: scrollView.contentOffset.x)
        delegate?.bannerViewWillBeginDragging(self)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if abs(velocity.x) < 0.35 || beginDragIndexSection != indexSection {
            targetContentOffset.pointee.x = caculateOffsetX(at: indexSection)
            return
        }
        
        let direction: MJPagerScrollDirection = (scrollView.contentOffset.x < 0 && targetContentOffset.pointee.x <= 0) ||
        (targetContentOffset.pointee.x < scrollView.contentOffset.x &&
         scrollView.contentOffset.x < scrollView.contentSize.width - scrollView.frame.width) ? .left : .right
        
        let indexSection = nearlyIndexPath(for: self.indexSection, direction: direction)
        targetContentOffset.pointee.x = caculateOffsetX(at: indexSection)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if autoScrollInterval > 0 {
            addTimer()
        }
        delegate?.bannerViewDidEndDragging(self, willDecelerate: decelerate)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.bannerViewWillBeginDecelerating(self)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        recycleBannerViewIfNeed()
        delegate?.bannerViewDidEndDecelerating(self)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        recycleBannerViewIfNeed()
        delegate?.bannerViewDidEndScrollingAnimation(self)
    }
}

// MARK: - MJBannerViewLayoutDelegate

extension MJBannerView: MJBannerViewLayoutDelegate {
    public func bannerViewTransformLayout(_ layout: MJBannerViewLayout, initializeTransformAttributes attributes: UICollectionViewLayoutAttributes) {
        delegate?.bannerView(self, initializeTransformAttributes: attributes)
    }
    
    public func bannerViewTransformLayout(_ layout: MJBannerViewLayout, applyTransformToAttributes attributes: UICollectionViewLayoutAttributes) {
        delegate?.bannerView(self, applyTransformToAttributes: attributes)
    }
}
