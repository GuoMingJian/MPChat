//
//  BaseScrollView.swift
//  MJKit
//
//  Created by 郭明健 on 2025/10/15.
//

import UIKit
import MJRefresh

public class BaseScrollView: UIScrollView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        //
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.isScrollEnabled = true
        self.contentInsetAdjustmentBehavior = .never
        self.backgroundColor = .clear
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
