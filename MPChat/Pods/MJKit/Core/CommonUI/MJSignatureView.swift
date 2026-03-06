//
//  MJSignatureView.swift
//
//  Created by 郭明健 on 2025/6/7.
//

/*
 签名View
 let signatureView = MJSignatureView()
 view.addSubview(signatureView)
 NSLayoutConstraint.activate([
 signatureView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
 signatureView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
 signatureView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
 signatureView.heightAnchor.constraint(equalToConstant: 300)
 ])
 */

import UIKit

public class MJSignatureView: UIView {
    // MARK: - Properties
    public var lineWidth: CGFloat = 2.0 {
        didSet {
            self.path.lineWidth = lineWidth
            // 同时更新所有已保存路径的线宽？不更新已保存的，保持历史路径样式
        }
    }
    public var strokeColor: UIColor = UIColor.black
    public var signatureBackgroundColor: UIColor = UIColor.white
    
    // MARK: - Private Properties
    private var paths: [UIBezierPath] = [] // 存储每条路径
    private var path = UIBezierPath()
    private var pts = [CGPoint](repeating: CGPoint(), count: 5)
    private var ctr = 0
    
    // MARK: - Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = self.signatureBackgroundColor
        self.path.lineWidth = self.lineWidth
    }
    
    // MARK: - Drawing
    public override func draw(_ rect: CGRect) {
        self.strokeColor.setStroke()
        for bezierPath in paths {
            bezierPath.stroke()
        }
        self.path.stroke()
    }
    
    // MARK: - Touch Handling
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let touchPoint = firstTouch.location(in: self)
            self.ctr = 0
            self.pts[0] = touchPoint
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let touchPoint = firstTouch.location(in: self)
            self.ctr += 1
            self.pts[self.ctr] = touchPoint
            if (self.ctr == 4) {
                self.pts[3] = CGPoint(x: (self.pts[2].x + self.pts[4].x) / 2.0, y: (self.pts[2].y + self.pts[4].y) / 2.0)
                self.path.move(to: self.pts[0])
                self.path.addCurve(to: self.pts[3], controlPoint1:self.pts[1],
                                   controlPoint2:self.pts[2])
                self.setNeedsDisplay()
                self.pts[0] = self.pts[3]
                self.pts[1] = self.pts[4]
                self.ctr = 1
            }
            self.setNeedsDisplay()
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.ctr == 0 {
            let touchPoint = self.pts[0]
            self.path.move(to: CGPoint(x: touchPoint.x - 1.0,y: touchPoint.y))
            self.path.addLine(to: CGPoint(x: touchPoint.x + 1.0,y: touchPoint.y))
            self.setNeedsDisplay()
        } else {
            // 保存当前路径到数组
            paths.append(path.copy() as! UIBezierPath)
            
            // 创建新路径并保持相同的配置
            self.path = UIBezierPath()
            self.path.lineWidth = self.lineWidth
            
            self.ctr = 0
        }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    // MARK: - Public Methods
    /// 签名视图清空
    public func clearSignature() {
        self.paths.removeAll() // 清空路径数组
        self.path.removeAllPoints()
        self.path.lineWidth = self.lineWidth // 重置线宽
        self.setNeedsDisplay()
    }
    
    /// 回滚上一步
    public func undo() {
        _ = paths.popLast() // 移除最后一条路径
        self.setNeedsDisplay() // 重新绘制
    }
    
    /// 将签名保存为UIImage
    public func getSignature() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: self.bounds.size.width, height: self.bounds.size.height))
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let signature: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return signature
    }
    
    /// 检查是否有签名
    public func hasSignature() -> Bool {
        return !paths.isEmpty || !path.isEmpty
    }
}

// MARK: - UIBezierPath Extension
extension UIBezierPath {
    var isEmpty: Bool {
        return self.bounds.isEmpty || self.bounds.size == .zero
    }
}
