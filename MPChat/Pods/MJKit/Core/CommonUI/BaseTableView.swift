//
//  BaseTableView.swift
//  MJKit
//
//  Created by 郭明健 on 2025/10/15.
//

import UIKit
import MJRefresh
import EmptyDataSet_Swift

public class BaseTableView: UITableView {
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.translatesAutoresizingMaskIntoConstraints = false
        //
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.estimatedSectionFooterHeight = 0
        self.estimatedSectionHeaderHeight = 0
        self.contentInsetAdjustmentBehavior = .never
        self.separatorStyle = .none
        self.backgroundColor = .white
        self.bounces = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    /// 文字/菊花颜色（默认黑色）
    public var loadingColor: UIColor?
    
    /// 是否支持下拉刷新
    public var isCanRefresh: Bool = false {
        didSet {
            setupHeaderRefresh()
        }
    }
    /// 是否支持上拉加载更多
    public var isCanLoadMore: Bool = false {
        didSet {
            setupFooterRefresh()
        }
    }
    /// 是否展示无数据模式
    public var isShowNoDataStyle: Bool = false {
        didSet {
            if isShowNoDataStyle {
                setupNoData()
            }
        }
    }
    
    /// 是否经过网络请求（避免首次进来展示noData样式）
    public var isRequested: Bool = false
    /// 无数据 image
    public var noDataImage: UIImage?
    /// 无数据 title
    public var noDataTitle: String?
    /// 无数据 title 字体颜色
    public var noDataTextColor: UIColor?
    
    // MARK: - Block
    public var headerRefreshBlock: (() -> Void)?
    public var footerRefreshBlock: (() -> Void)?
    
    // MARK: -
    private let mjHeader = MJRefreshNormalHeader()
    private let mjFooter = MJRefreshBackNormalFooter()
    
    // MARK: -
    public func endRefresh(isHasMoreData: Bool = true) {
        self.mjHeader.endRefreshing()
        if isHasMoreData {
            self.mjFooter.endRefreshing()
        } else {
            self.mjFooter.endRefreshingWithNoMoreData()
        }
    }
    
    private func setupHeaderRefresh() {
        if isCanRefresh {
            // refreshing
            mjHeader.setRefreshingTarget(self, refreshingAction: #selector(mjHeaderRefresh))
            // 文字/菊花颜色
            if let loadingColor = loadingColor {
                mjHeader.stateLabel?.textColor = loadingColor
                mjHeader.lastUpdatedTimeLabel?.textColor = loadingColor
                mjHeader.loadingView?.color = loadingColor
                // 隐藏文字
                //mjHeader.stateLabel?.isHidden = true
                //mjHeader.lastUpdatedTimeLabel?.isHidden = true
            }
            self.mj_header = mjHeader
        } else {
            self.mj_header = nil
        }
    }
    
    private func setupFooterRefresh() {
        if isCanLoadMore {
            // load more
            mjFooter.setRefreshingTarget(self, refreshingAction: #selector(mjFooterRefresh))
            mjFooter.resetNoMoreData()
            // 文字/菊花颜色
            if let loadingColor = loadingColor {
                mjFooter.stateLabel?.textColor = loadingColor
                mjFooter.loadingView?.color = loadingColor
            }
            self.mj_footer = mjFooter
        } else {
            self.mj_footer = nil
        }
    }
    
    private func setupNoData() {
        // https://github.com/Xiaoye220/EmptyDataSet-Swift
        self.emptyDataSetSource = self
        self.emptyDataSetDelegate = self
    }
    
    // MARK: - actions
    @objc private func mjHeaderRefresh() {
        if headerRefreshBlock != nil {
            headerRefreshBlock!()
        }
    }
    
    @objc private func mjFooterRefresh() {
        if footerRefreshBlock != nil {
            footerRefreshBlock!()
        }
    }
}

extension BaseTableView: EmptyDataSetSource, EmptyDataSetDelegate {
    public func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        if isRequested {
            var resultImage: UIImage = "mj_noData".mj_Image()
            if let image = noDataImage {
                resultImage = image
            }
            return resultImage
        }
        return nil
    }
    
    public func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if isRequested {
            var string: String = "no_data".mj_Localized()
            if let noDataString = noDataTitle {
                string = noDataString
            }
            let font = UIFont.systemFont(ofSize: 14, weight: .regular)
            var textColor: UIColor = UIColor.hexColor(color: "#5F5B78")
            if let color = noDataTextColor {
                textColor = color
            }
            let attributedString = NSAttributedString(string: string, attributes: [ NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor])
            return attributedString
        }
        return nil
    }
    
    public func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    public func emptyDataSetDidAppear(_ scrollView: UIScrollView) {
        // 自动忽略首次noData样式（未经过请求），非首次都是请求之后的noData样式
        isRequested = true
    }
}
