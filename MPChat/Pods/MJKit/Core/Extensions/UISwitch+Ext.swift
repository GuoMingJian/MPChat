//
//  UISwitch+Extension.swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

// MARK: -
public extension UISwitch {
    func toggle() {
        self.setOn(!self.isOn, animated: true)
    }
    
    func setHandle(event: UIControl.Event = .touchUpInside,
                   callBlock: ((_ isOn: Bool) -> Void)? = nil) {
        self.mjCallBack = { isOn in
            if let block = callBlock, let isOn = isOn {
                block(isOn)
            }
        }
        self.addTarget(self, action: #selector(self.switchAction), for: event)
    }
}

private var MJUISwitchCallBackKey: Void?
extension UISwitch: MJBlockProtocol {
    public typealias T = Bool
    public var mjCallBack: MJCallBack? {
        get {
            return mj_getAssociatedObject(self, &MJUISwitchCallBackKey)
        }
        set {
            mj_setRetainedAssociatedObject(self, &MJUISwitchCallBackKey, newValue)
        }
    }
    
    @objc internal func switchAction(_ event: UISwitch) {
        self.mjCallBack?(event.isOn)
    }
}
