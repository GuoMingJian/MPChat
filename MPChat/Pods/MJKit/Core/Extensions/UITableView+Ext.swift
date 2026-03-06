//
//  UITableView+Ext.swift
//  MJKit
//
//  Created by 郭明健 on 2025/10/11.
//

import UIKit

public extension UITableViewCell {
    static func reuse() -> String {
        return "\(self)"
    }
}

public extension UICollectionReusableView {
    static func reuse() -> String {
        return "\(self)"
    }
}

public extension UITableViewHeaderFooterView {
    static func reuse() -> String {
        return "\(self)"
    }
}

public extension UITableView {
    func registerCell(_ cellClass: UITableViewCell.Type) {
        self.register(cellClass.self, forCellReuseIdentifier: cellClass.reuse())
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type) -> T {
        return self.dequeueReusableCell(withIdentifier: cellClass.reuse()) as! T
    }
    
    func registerHeaderFooterView(_ viewClass: UITableViewHeaderFooterView.Type){
        self.register(viewClass.self, forHeaderFooterViewReuseIdentifier: viewClass.reuse())
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: viewClass.reuse()) as! T
    }
    
    func setAndLayoutTableHeaderView(header: UIView) {
        self.tableHeaderView = header
        
        for view in header.subviews {
            guard let label = view as? UILabel, label.numberOfLines == 0 else { continue }
            label.preferredMaxLayoutWidth = label.frame.width
        }
        
        header.setNeedsLayout()
        header.layoutIfNeeded()
        var frame = header.frame
        
        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        frame.size = size
        
        header.frame = frame
        self.tableHeaderView = header
    }
}

public extension UICollectionView {
    func registerCell<T: UICollectionViewCell>(_ cellClass: T.Type) {
        self.register(cellClass.self, forCellWithReuseIdentifier: cellClass.reuse())
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: cellClass.reuse(), for: indexPath) as! T
    }
    
    func registerSectionHeader<T: UICollectionReusableView>(_ cellClass: T.Type) {
        self.register(cellClass.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cellClass.reuse())
    }
    
    func dequeueReusableSectionHeader<T: UICollectionReusableView>(_ cellClass: T.Type, indexPath: IndexPath) -> T {
        return self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cellClass.reuse(), for: indexPath) as! T
    }
    
}
