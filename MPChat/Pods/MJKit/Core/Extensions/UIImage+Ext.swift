//
//  UIImage+Ext.swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit
import CryptoKit

// MARK: ===== UIImage =====
public extension UIImage {
    // MARK: 判断 UIImage 是否为空
    /// 判断 UIImage 是否为空
    var isEmpty: Bool {
        return self.size == .zero
    }
    
    // MARK: Image 转 base64 String
    /// Image 转 base64 String
    static func imageToString(image: UIImage) -> String? {
        if let imageData = image.pngData() {
            let base64String = imageData.base64EncodedString()
            return base64String
        }
        return nil
    }
    
    // MARK: base64 String 转 Image
    /// base64 String 转 Image
    static func stringToImage(base64String: String) -> UIImage? {
        if let imageData = Data(base64Encoded: base64String) {
            let image = UIImage(data: imageData)
            return image
        }
        return nil
    }
    
    // MARK: Image 转 md5
    /// Image 转 md5
    func md5(isPNG: Bool = true) -> String {
        var imageData: Data?
        if isPNG {
            guard let data = self.pngData() else { return "" }
            imageData = data
        } else {
            guard let data = self.jpegData(compressionQuality: 1) else { return "" }
            imageData = data
        }
        if let imageData = imageData {
            let digest = Insecure.MD5.hash(data: imageData)
            return digest.map { String(format: "%02hhx", $0) }.joined()
        }
        return ""
    }
    
    // MARK: 图片大小 Bytes
    /// 图片大小 Bytes
    func imageSizeInBytes() -> Int? {
        guard let data = self.pngData() else { return nil }
        return data.count
    }
    
    // MARK: 图片加水印
    /// 图片加水印
    func drawWatermark(watermark: UIView,
                       position: CGPoint) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        // 确保上下文在结束时被关闭
        defer { UIGraphicsEndImageContext() }
        // 绘制原始图像
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        // 水印 view 的截图
        let waterImage = watermark.screenshotsImage()
        waterImage.draw(at: position)
        // 获取合成后的图像
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        return image
    }
    
    // MARK: 给原始图片底色
    /// 给原始图片底色
    static func imageName(name: String,
                          tintColor: UIColor) -> UIImage? {
        let image = UIImage(named: name)?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
        return image
    }
    
    // MARK: 创建渐变色
    /// 创建渐变色
    static func gradientImageWithBounds(bounds: CGRect,
                                        colors: [CGColor]) -> UIImage {
        if bounds == .zero {
            return UIImage.creatColorImage(.black)
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        // 确保上下文在结束时被关闭
        defer { UIGraphicsEndImageContext() }
        
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            // 获取合成后的图像
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                return image
            }
        }
        return UIImage()
    }
    
    // MARK: 用颜色创建一张图片
    /// 用颜色创建一张图片
    static func creatColorImage(_ color: UIColor,
                                _ ARect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)) -> UIImage {
        let rect = ARect
        UIGraphicsBeginImageContext(rect.size)
        // 确保上下文在结束时被关闭
        defer { UIGraphicsEndImageContext() }
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(rect)
            // 获取合成后的图像
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                return image
            }
        }
        
        return UIImage()
    }
    
    // MARK: 给图片设置透明度
    /// 给图片设置透明度
    func withAlpha(_ alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage else { return nil }
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -self.size.height)
        context.setBlendMode(.normal)
        context.setAlpha(alpha)
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // MARK: 给Image添加圆角
    /// 给Image添加圆角
    func setCornerRadius(radius: CGFloat,
                         sizeToFit: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: sizeToFit)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        // 确保上下文在结束时被关闭
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        // 添加圆角路径并裁剪
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
        context.addPath(path.cgPath)
        context.clip()
        // 绘制图像
        self.draw(in: rect)
        // 获取合成后的图像
        guard let output = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        return output
    }
    
    // MARK: 重设图片大小
    /// 重设图片大小
    func resetImageSize(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        // 确保上下文在结束时被关闭
        defer { UIGraphicsEndImageContext() }
        // 绘制图像
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        // 获取合成后的图像
        guard let reSizeImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        return reSizeImage
    }
    
    // MARK: 等比例缩放
    /// 等比例缩放
    func scaleImage(scale: CGFloat) -> UIImage {
        let size = CGSizeMake(self.size.width * scale, self.size.height * scale)
        return self.resetImageSize(size)
    }
    
    // MARK: 图片旋转
    /// 图片旋转
    func rotate(radians: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let degrees = radians.radiansToDegrees
        context.rotate(by: degrees)
        self.draw(in: CGRect(x: -self.size.width, y: -self.size.height, width: self.size.width, height: self.size.height))
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage
    }
    
    // MARK: 图片镜像转换
    /// 图片镜像转换
    func flippedOrientationImage() -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: .upMirrored)
    }
    
    /// 复原镜像图片
    func restoredOrientationImage() -> UIImage? {
        guard self.imageOrientation == .upMirrored, let cgImage = self.cgImage else {
            return self
        }
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: .up)
    }
}

// MARK: - ===== UIImage(二维码生成) =====
public extension UIImage {
    /// 二维码生成
    static func setupQRCodeImage(_ text: String,
                                 image: UIImage?) -> UIImage {
        // 创建滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        // 将url加入二维码
        filter?.setValue(text.data(using: String.Encoding.utf8), forKey: "inputMessage")
        // 取出生成的二维码（不清晰）
        if let outputImage = filter?.outputImage {
            // 生成清晰度更好的二维码
            let qrCodeImage = setupHighDefinitionUIImage(outputImage, size: 300)
            // 如果有一个头像的话，将头像加入二维码中心
            if var image = image {
                // 白色圆边
                // image = circleImageWithImage(image, borderWidth: 50, borderColor: UIColor.white)
                // 白色圆角矩形边
                image = rectangleImageWithImage(image, borderWidth: 50, borderColor: UIColor.white)
                // 合成图片
                let newImage = syntheticImage(qrCodeImage, iconImage: image, width: 70, height: 70)
                
                return newImage
            }
            return qrCodeImage
        }
        //
        return UIImage()
    }
    
    /// 生成高清的UIImage
    private static func setupHighDefinitionUIImage(_ image: CIImage,
                                                   size: CGFloat) -> UIImage {
        let integral: CGRect = image.extent.integral
        let proportion: CGFloat = min(size / integral.width, size / integral.height)
        
        let width = integral.width * proportion
        let height = integral.height * proportion
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        
        // 创建位图上下文
        guard let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: 0) else {
            return UIImage()
        }
        let context = CIContext(options: nil)
        
        // 创建 CGImage
        guard let bitmapImage = context.createCGImage(image, from: integral) else {
            return UIImage()
        }
        
        bitmapRef.interpolationQuality = .none
        bitmapRef.scaleBy(x: proportion, y: proportion)
        bitmapRef.draw(bitmapImage, in: integral)
        
        // 获取合成后的 CGImage
        guard let outputImage = bitmapRef.makeImage() else {
            return UIImage()
        }
        
        return UIImage(cgImage: outputImage)
    }
    
    /// 生成矩形边框
    private static func rectangleImageWithImage(_ sourceImage: UIImage,
                                                borderWidth: CGFloat,
                                                borderColor: UIColor) -> UIImage {
        let imageWidth = sourceImage.size.width + 2 * borderWidth
        let imageHeight = sourceImage.size.height + 2 * borderWidth
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageWidth, height: imageHeight), false, 0.0)
        // 确保上下文在结束时被关闭
        defer { UIGraphicsEndImageContext() }
        
        guard let _ = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        let bezierPath = UIBezierPath(roundedRect: CGRect(x: borderWidth, y: borderWidth, width: sourceImage.size.width, height: sourceImage.size.height), cornerRadius: 1)
        bezierPath.lineWidth = borderWidth
        borderColor.setStroke()
        bezierPath.stroke()
        bezierPath.addClip()
        
        sourceImage.draw(in: CGRect(x: borderWidth, y: borderWidth, width: sourceImage.size.width, height: sourceImage.size.height))
        
        // 获取合成后的图像
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        
        return image
    }
    
    /// 生成圆形边框
    private static func circleImageWithImage(_ sourceImage: UIImage,
                                             borderWidth: CGFloat,
                                             borderColor: UIColor) -> UIImage {
        let imageWidth = sourceImage.size.width + 2 * borderWidth
        let imageHeight = sourceImage.size.height + 2 * borderWidth
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageWidth, height: imageHeight), false, 0.0)
        // 确保上下文在结束时被关闭
        defer { UIGraphicsEndImageContext() }
        
        guard let _ = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        let radius = min(sourceImage.size.width, sourceImage.size.height) * 0.5
        let bezierPath = UIBezierPath(arcCenter: CGPoint(x: imageWidth * 0.5, y: imageHeight * 0.5), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        bezierPath.lineWidth = borderWidth
        borderColor.setStroke()
        bezierPath.stroke()
        bezierPath.addClip()
        
        // 绘制图像
        sourceImage.draw(in: CGRect(x: borderWidth, y: borderWidth, width: sourceImage.size.width, height: sourceImage.size.height))
        
        // 获取合成后的图像
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        
        return image
    }
    
    /// image: 二维码 iconImage:头像图片 width: 头像的宽 height: 头像的宽
    private static func syntheticImage(_ image: UIImage,
                                       iconImage:UIImage,
                                       width: CGFloat,
                                       height: CGFloat) -> UIImage {
        // 开启图片上下文
        UIGraphicsBeginImageContext(image.size)
        // 绘制背景图片
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let x = (image.size.width - width) * 0.5
        let y = (image.size.height - height) * 0.5
        iconImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        // 取出绘制好的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        // 关闭上下文
        UIGraphicsEndImageContext()
        // 返回合成好的图片
        if let newImage = newImage {
            return newImage
        }
        return UIImage()
    }
}
