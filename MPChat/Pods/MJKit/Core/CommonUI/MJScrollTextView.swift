//
//  MJScrollTextView.swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

/*
 private lazy var scrollTextView: MJScrollTextView = {
 let view = MJScrollTextView()
 view.translatesAutoresizingMaskIntoConstraints = false
 view.backgroundColor = UIColor.black(alpha: 0.1)
 return view
 }()
 
 view.addSubview(scrollTextView)
 NSLayoutConstraint.activate([
 scrollTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
 scrollTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
 scrollTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
 scrollTextView.heightAnchor.constraint(equalToConstant: 60),
 ])
 
 var scrollConfig = MJScrollTextView.Configuration()
 scrollConfig.titles = ["风急天高猿啸哀，",
 "云淡风轻鹤归来。",
 "无边落木萧萧下",
 "不尽长江滚滚来"]
 scrollTextView.show(configuration: scrollConfig)
 */

/// 滚动文本
public class MJScrollTextView: UIView {
    /// 滚动方向，默认上下滚动 vertical
    public enum ScrollDirection {
        case vertical
        case horizontal
    }
    
    public struct Configuration {
        public var titles: [String] = []
        public var textFont: UIFont = UIFont.systemFont(ofSize: 16)
        public var textColor: UIColor = .black
        public var scrollDirection: ScrollDirection = .vertical
        public var timeInterval: TimeInterval = 3.0
        public var index: Int = 0
        public var leadingOffset: CGFloat = 10
        
        public init(titles: [String] = [],
                    textFont: UIFont = UIFont.systemFont(ofSize: 16),
                    textColor: UIColor = .black,
                    scrollDirection: ScrollDirection = .vertical,
                    timeInterval: TimeInterval = 3.0,
                    index: Int = 0,
                    leadingOffset: CGFloat = 10) {
            self.titles = titles
            self.textFont = textFont
            self.textColor = textColor
            self.scrollDirection = scrollDirection
            self.timeInterval = timeInterval
            self.index = index
            self.leadingOffset = leadingOffset
        }
        
        public init() {}
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public var onClickBlock: ((_ index: Int) -> Void)?
    
    // MARK: -
    private var kLblTag: Int = 100
    private var kBtnTag: Int = 1000
    private var config: Configuration = Configuration()
    private var timer: Timer?
    
    // MARK: - Public Methods
    public func show(configuration: Configuration) {
        self.config = configuration
        //
        setupViews()
    }
    
    public func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    public func restart() {
        stop()
        setupViews()
    }
    
    public func updateTitles(_ titles: [String]) {
        config.titles = titles
        config.index = 0
        restart()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        self.removeAllSubviews()
        //
        self.layoutIfNeeded()
        self.setNeedsLayout()
        if config.titles.count > 0 {
            let index = config.index
            let title = config.titles[index]
            //
            let lbl = UILabel(frame: CGRect(x: config.leadingOffset, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            lbl.tag = index + kLblTag
            lbl.text = title
            lbl.textColor = config.textColor
            lbl.font = config.textFont
            lbl.textAlignment = .left
            lbl.numberOfLines = 0
            self.addSubview(lbl)
            //
            let btn = UIButton(frame: self.bounds)
            btn.tag = index + kBtnTag
            btn.addTarget(self, action: #selector(onClick), for: .touchUpInside)
            self.addSubview(btn)
            //
            if config.titles.count > 1 {
                config.index += 1
                if let _ = timer {
                    return
                }
                timer = Timer.scheduledTimer(withTimeInterval: config.timeInterval, repeats: true) { [weak self] timer in
                    guard let self = self else {
                        timer.invalidate()
                        return
                    }
                    self.buildNextLabel()
                }
                if let timer = timer {
                    RunLoop.current.add(timer, forMode: .common)
                }
            }
        }
    }
    
    @objc private func buildNextLabel() {
        guard config.titles.count > 0 else { return }
        
        let index = config.index
        var oldIndex = config.index - 1
        if index == 0 {
            oldIndex = config.titles.count - 1
        }
        let title = config.titles[index]
        //
        guard let oldLbl = self.viewWithTag(oldIndex + kLblTag) as? UILabel,
              let oldBtn = self.viewWithTag(oldIndex + kBtnTag) as? UIButton else {
            return
        }
        //
        let newLbl = UILabel()
        if config.scrollDirection == .vertical {
            newLbl.frame = CGRect(x: config.leadingOffset, y: self.frame.size.height, width: self.frame.size.width, height: self.frame.size.height)
        } else {
            newLbl.frame = CGRect(x: config.leadingOffset + self.frame.size.width, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        }
        newLbl.tag = index + kLblTag
        newLbl.text = title
        newLbl.textColor = config.textColor
        newLbl.font = config.textFont
        newLbl.textAlignment = .left
        newLbl.numberOfLines = 0
        self.addSubview(newLbl)
        //
        var rect = newLbl.frame
        rect.origin.x = rect.origin.x - config.leadingOffset
        let newBtn = UIButton(frame: self.bounds)
        newBtn.tag = index + kBtnTag
        newBtn.addTarget(self, action: #selector(onClick(button:)), for: .touchUpInside)
        self.addSubview(newBtn)
        //
        oldLbl.alpha = 1
        newLbl.alpha = 0
        UIView.animate(withDuration: 0.3, animations: { [self] in
            oldLbl.alpha = 0
            newLbl.alpha = 1
            if self.config.scrollDirection == .vertical {
                oldLbl.frame = CGRect(x: config.leadingOffset, y: -self.frame.size.height, width: self.frame.size.width, height: self.frame.size.height)
                newLbl.frame = CGRect(x: config.leadingOffset, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            } else {
                oldLbl.frame = CGRect(x: -(config.leadingOffset + self.frame.size.width), y: 0, width: self.frame.size.width, height: self.frame.size.height)
                newLbl.frame = CGRect(x: config.leadingOffset, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            }
            newBtn.frame = newLbl.frame
        }, completion: {(finished) -> Void in
            oldLbl.removeFromSuperview()
            oldBtn.removeFromSuperview()
        })
        //
        config.index += 1
        if config.index >= config.titles.count {
            config.index = 0
        }
    }
    
    @objc private func onClick(button: UIButton) {
        onClickBlock?(button.tag - kBtnTag)
    }
    
    deinit {
        timer?.invalidate()
    }
}
