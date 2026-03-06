//
//  MJEmailTextField.swift
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

/*
 private lazy var emailTextField: MJEmailTextField = {
 let view = MJEmailTextField()
 view.translatesAutoresizingMaskIntoConstraints = false
 return view
 }()
 view.addSubview(emailTextField)
 NSLayoutConstraint.activate([
 emailTextField.topAnchor.constraint(equalTo: mySwitch.bottomAnchor, constant: 30),
 emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
 emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
 emailTextField.heightAnchor.constraint(equalToConstant: 50)
 ])
 var config = MJEmailTextField.Configuration()
 config.leftSpac = 10
 emailTextField.setCornerRadius(radius: 10)
 emailTextField.backgroundColor = UIColor.black(alpha: 0.05)
 emailTextField.setupEmailSuffixDelegate(configuration: config)
 */

public protocol MJEmailTextFieldDelegate: NSObjectProtocol {
    func textFieldDidBegin(_ textField: UITextField)
    func textFieldDidChange(_ textField: UITextField)
    func textFieldDidEnd(_ textField: UITextField, _ text: String)
}

public extension MJEmailTextFieldDelegate {
    func textFieldDidBegin(_ textField: UITextField) {}
    func textFieldDidChange(_ textField: UITextField) {}
    func textFieldDidEnd(_ textField: UITextField, _ text: String) {}
}

public class MJEmailTextField: UITextField {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clearButtonMode = .whileEditing
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public struct Configuration {
        public var emailSuffixList: [String] = ["@gmail.com",
                                                "@google.com",
                                                "@outlook.com",
                                                "@icloud.com",
                                                "@yahoo.com",
                                                "@qq.com",
                                                "@hotmail.com",
                                                "@aol.com",
                                                "@inbox.com",
                                                "@zohomail.com"]
        public var maxShowRowCount: Int = 6
        // tableView与TextField间距
        public var yOffset: CGFloat = 10
        public var shadowRadius: CGFloat = 10
        public var cellHeight: CGFloat = 40
        public var font: UIFont = UIFont.systemFont(ofSize: 14)
        // 当内容超长时，输入内容展示最大个数，如"...222344@qq.com"
        public var maxOmitCount: Int = 6
        public var leftSpac: CGFloat = 10
        
        public init(emailSuffixList: [String] = ["@gmail.com", "@google.com", "@outlook.com", "@icloud.com", "@yahoo.com", "@qq.com", "@hotmail.com", "@aol.com", "@inbox.com", "@zohomail.com"],
                    maxShowRowCount: Int = 6,
                    yOffset: CGFloat = 10,
                    shadowRadius: CGFloat = 10,
                    cellHeight: CGFloat = 40,
                    font: UIFont = UIFont.systemFont(ofSize: 14),
                    maxOmitCount: Int = 6,
                    leftSpac: CGFloat = 10) {
            self.emailSuffixList = emailSuffixList
            self.maxShowRowCount = maxShowRowCount
            self.yOffset = yOffset
            self.shadowRadius = shadowRadius
            self.cellHeight = cellHeight
            self.font = font
            self.maxOmitCount = maxOmitCount
            self.leftSpac = leftSpac
        }
        
        public init() {}
    }
    
    // MARK: -
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = true
        tableView.bounces = true
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        // 设置分隔符样式
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .lightGray.withAlphaComponent(0.3)
        //
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        return tableView
    }()
    
    private lazy var shadowView: UIView = {
        let shadowView = UIView()
        shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.shadowRadius = configuration.shadowRadius
        return shadowView
    }()
    
    // MARK: -
    private var configuration: Configuration = Configuration()
    private var inputText: String = "" {
        didSet {
            if isOpenEmailPopView {
                //print("==> \(inputText)")
                //
                if inputText.count > 0 {
                    filterEmailList = getFilterEmail()
                } else {
                    dismiss()
                }
            }
        }
    }
    private var filterEmailList: [String] = [] {
        didSet {
            if filterEmailList.count > 0 {
                //print("==> emailList: \(filterEmailList)")
                updateEmailPopview()
            } else {
                dismiss()
            }
        }
    }
    private var isHiddenPopView: Bool = false {
        didSet {
            if isHiddenPopView {
                var time: TimeInterval = 0
                if !self.isEmail() {
                    time = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: { [weak self] in
                    guard let self = self else { return }
                    if self.isHiddenPopView,
                       self.filterEmailList.count > 0,
                       self.inputText.count > 0 {
                        self.dismiss()
                        self.isHiddenPopView = false
                    }
                })
            }
        }
    }
    
    // MARK: - Public
    public weak var mj_delegate: MJEmailTextFieldDelegate?
    public var isOpenEmailPopView: Bool = false
    
    public func setupEmailSuffixDelegate(configuration: Configuration = Configuration()) {
        self.configuration = configuration
        self.isOpenEmailPopView = true
        self.setTextLeadingSpac(configuration.leftSpac)
        self.addTarget(self, action: #selector(textFieldDidBegin(_:)), for: .editingDidBegin)
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.addTarget(self, action: #selector(textFieldDidEnd(_:)), for: .editingDidEnd)
    }
    
    public func dismiss() {
        shadowView.removeFromSuperview()
        self.resignFirstResponder()
    }
    
    // MARK: - actions
    @objc public func textFieldDidBegin(_ textField: UITextField) {
        let text = textField.text ?? ""
        if text.count > 0 {
            inputText = text
        }
        if let delegate = mj_delegate {
            delegate.textFieldDidBegin(textField)
        }
    }
    
    @objc public func textFieldDidChange(_ textField: UITextField) {
        inputText = textField.text ?? ""
        if let delegate = mj_delegate {
            delegate.textFieldDidChange(textField)
        }
    }
    
    @objc public func textFieldDidEnd(_ textField: UITextField) {
        isHiddenPopView = true
        if let delegate = mj_delegate {
            delegate.textFieldDidEnd(textField, textField.text ?? "")
        }
    }
    
    // MARK: -
    private func getFilterEmail() -> [String] {
        var tempList: [String] = []
        //
        if inputText.contains("@") {
            let prefix: String = inputText.components(separatedBy: "@").first ?? ""
            let suffix: String = "@" + (inputText.components(separatedBy: "@").last ?? "")
            for (_, item) in configuration.emailSuffixList.enumerated() {
                if item.contains(suffix) {
                    let value = prefix + item
                    tempList.append(value)
                }
            }
        } else {
            for (_, item) in configuration.emailSuffixList.enumerated() {
                let value = "\(inputText)\(item)"
                tempList.append(value)
            }
        }
        return tempList
    }
    
    private func updateEmailPopview() {
        if let keyWindow = UIView.getKeyWindow() {
            let tempRect = self.convert(self.bounds, to: keyWindow)
            let startPoint: CGPoint = CGPoint(x: tempRect.minX, y: tempRect.maxY + configuration.yOffset)
            //
            var showRowCount = filterEmailList.count
            if showRowCount > configuration.maxShowRowCount {
                showRowCount = configuration.maxShowRowCount
            }
            //
            let popViewHeight: CGFloat = CGFloat(showRowCount) * configuration.cellHeight
            var popViewWidth: CGFloat = 200
            let longestString: String = filterEmailList.max(by: { $0.count < $1.count }) ?? ""
            let maxEmailWidth: CGFloat = ceil(longestString.textWidth(font: configuration.font, height: configuration.cellHeight)) + 20 * 2
            if maxEmailWidth > popViewWidth {
                popViewWidth = maxEmailWidth
                //
                let maxShowWidth: CGFloat = MJ.kScreenWidth - startPoint.x - 16
                if popViewWidth > maxShowWidth {
                    popViewWidth = maxShowWidth
                    // 从开始点计算，宽度已经超出屏幕了，需要更改展示cell。不然导致邮箱类型显示不全
                    var newList: [String] = []
                    for (_, item) in filterEmailList.enumerated() {
                        let prefix: String = item.components(separatedBy: "@").first ?? ""
                        let suffix: String = "@" + (item.components(separatedBy: "@").last ?? "")
                        if prefix.count >= configuration.maxOmitCount {
                            var value = (prefix as NSString).substring(from: prefix.count - configuration.maxOmitCount)
                            value = "..." + value + suffix
                            newList.append(value)
                        } else {
                            newList.append(item)
                        }
                    }
                    filterEmailList = newList
                    return
                }
            }
            //
            let rect: CGRect = CGRect(x: startPoint.x, y: startPoint.y, width: popViewWidth, height: popViewHeight)
            showPopview(rect: rect, keyWindow: keyWindow)
        }
    }
    
    private func showPopview(rect: CGRect,
                             keyWindow: UIView) {
        // 阴影&圆角，特殊处理
        shadowView.frame = rect
        shadowView.addSubview(tableView)
        tableView.layer.cornerRadius = configuration.shadowRadius
        tableView.layer.masksToBounds = true
        tableView.rowHeight = configuration.cellHeight
        tableView.frame = shadowView.bounds
        //
        keyWindow.addSubview(shadowView)
        //
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .middle, animated: true)
    }
    
    private func isEmail() -> Bool {
        let text = self.text ?? ""
        if text.count == 0 {
            return false
        }
        let rgex = "^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(.[a-zA-Z0-9_-]+)+$"
        let checker: NSPredicate = NSPredicate(format: "SELF MATCHES %@", rgex)
        return checker.evaluate(with: text)
    }
    
    private func setTextLeadingSpac(_ leftSpac: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: leftSpac, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MJEmailTextField: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterEmailList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
        let text = filterEmailList[indexPath.row]
        cell.textLabel?.text = text
        cell.textLabel?.font = configuration.font
        cell.textLabel?.textColor = UIColor.black
        cell.backgroundColor = UIColor.white
        //cell.selectionStyle = .none
        //
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isHiddenPopView = false
        let cellValue = filterEmailList[indexPath.row]
        let suffix: String = "@" + (cellValue.components(separatedBy: "@").last ?? "")
        let text = self.text ?? ""
        let prefix: String = text.components(separatedBy: "@").first ?? ""
        self.text = prefix + suffix
        if let delegate = mj_delegate {
            delegate.textFieldDidEnd(self, self.text ?? "")
        }
        dismiss()
    }
    
    // MARK: -
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - UIScrollViewDelegate
extension MJEmailTextField: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isHiddenPopView = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { [weak self] in
            guard let self = self else { return }
            self.isHiddenPopView = true
        })
    }
}
