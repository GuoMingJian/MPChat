//
//  ZLPicker.swift
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit
import Photos
import ZLPhotoBrowser

/// 系统文件数据
public struct MJSystemFileInfo: Codable {
    var id: Int = 0
    var url: String = ""
    var fileType: String = ""
    var fileName: String = ""
    var realName: String = ""
    var data: Data = Data()
    // data 转成 string
    var dataString: String = ""
    
    public init() {}
    public init(id: Int, url: String, fileType: String, fileName: String, realName: String, data: Data, dataString: String) {
        self.id = id
        self.url = url
        self.fileType = fileType
        self.fileName = fileName
        self.realName = realName
        self.data = data
        self.dataString = dataString
    }
    
    public func getImage() -> UIImage {
        let image = UIImage(data: data) ?? UIImage()
        return image
    }
}

public class ZLPicker {
    public static let shared = ZLPicker()
    private init() {}
    
    // MARK: - 打开相册
    /// 打开相册
    public func openPhotoLibrary(currentVC: UIViewController,
                                 maxSelectCount: Int = 1,
                                 allowSelectImage: Bool = true,
                                 allowSelectVideo: Bool = false,
                                 compeleted: @escaping ((_ fileDataList: [MJSystemFileInfo]) -> Void)) {
        let configuration = ZLPhotoConfiguration.default()
        // 最多选择x项
        configuration.maxSelectCount = maxSelectCount
        // 是否允许选择照片
        configuration.allowSelectImage = allowSelectImage
        // 是否允许选择视频
        configuration.allowSelectVideo = allowSelectVideo
        // 是否允许编辑图片
        configuration.allowEditImage = true
        // 是否允许编辑视频
        configuration.allowEditVideo = true
        // 是否允许勾选原图
        configuration.allowSelectOriginal = true
        //
        MJAuthorization.requestAuth(type: .photoReadWrite) {
            DispatchQueue.main.async {
                let picker = ZLPhotoPreviewSheet()
                //
                picker.selectImageBlock = { results, isOriginal in
                    var fileDataList: [MJSystemFileInfo] = []
                    for (_, result) in results.enumerated() {
                        ZLPicker.shared.getPhotoBrowserData(result: result) { data in
                            fileDataList.append(data)
                            if fileDataList.count == results.count {
                                // 筛选有文件名的
                                let newList = fileDataList.filter({ $0.fileName.count > 0 })
                                compeleted(newList)
                            }
                        }
                    }
                }
                //
                picker.showPhotoLibrary(sender: currentVC)
            }
        }
    }
    
    // MARK: - 打开相机
    /// 打开相机
    public func openCamera(currentVC: UIViewController,
                           compeleted: @escaping ((_ image: UIImage) -> Void)) {
        MJAuthorization.requestAuth(type: .camera) {
            DispatchQueue.main.async {
                let camera = ZLCustomCamera()
                camera.takeDoneBlock = { (image, videoUrl) in
                    if let image: UIImage = image {
                        compeleted(image)
                    }
                }
                currentVC.showDetailViewController(camera, sender: nil)
            }
        }
    }
}

public extension ZLPicker {
    // MARK: - 文件 Url 转 Data
    /// Url -> Data
    func systemUrlToData(url: URL,
                         isNeedAccessingSecurity: Bool = true) -> MJSystemFileInfo {
        var fileData: MJSystemFileInfo = MJSystemFileInfo()
        fileData.id = String.randomIntString(length: 10)
        do {
            // 获取data
            var isAccessing: Bool = true
            if isNeedAccessingSecurity {
                isAccessing = url.startAccessingSecurityScopedResource()
            }
            if isAccessing {
                let path = url.path
                fileData.url = path
                if path.contains("/") {
                    if let fileName: String = path.components(separatedBy: "/").last {
                        let dateStr = Date.dateToString(date: Date(), dateFormat: MJ.yyyyMMddHHmmss)
                        let randomString = String.randomString(length: 4) + "_" + dateStr
                        fileData.fileName = randomString + "_" + fileName
                        fileData.realName = fileName
                        if fileName.contains(".") {
                            if let fileType: String = fileName.components(separatedBy: ".").last {
                                fileData.fileType = fileType.lowercased()
                            }
                        }
                    }
                }
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                fileData.data = data
                let base64String = data.base64EncodedString()
                fileData.dataString = base64String
                
                if isNeedAccessingSecurity {
                    url.stopAccessingSecurityScopedResource()
                }
            }
        } catch {
            print("==> 根据URL读取系统文件发生错误: \(error)")
            // "An error occurred while reading file data!"
            UIView.showTips("load_system_file_error".mj_Localized(), duration: 3)
        }
        return fileData
    }
}

public extension ZLPicker {
    // MARK: - 保存图片到相册
    /// 保存图片到相册
    func saveImageToAlbum(image: UIImage,
                          completion: ((Bool, PHAsset?) -> Void)?) {
        MJAuthorization.requestAuth(type: .photoReadWrite) {
            var placeholderAsset: PHObjectPlaceholder?
            PHPhotoLibrary.shared().performChanges({
                let newAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                placeholderAsset = newAssetRequest.placeholderForCreatedAsset
            }) { suc, _ in
                DispatchQueue.main.async {
                    if suc {
                        let asset = self.getAsset(from: placeholderAsset?.localIdentifier)
                        completion?(suc, asset)
                    } else {
                        completion?(false, nil)
                    }
                }
            }
        } failure: {
            // 无相册权限
            completion?(false, nil)
        }
    }
    
    // MARK: - 保存视频到相册
    /// 保存视频到相册
    func saveVideoToAlbum(videoData: Data,
                          completion: @escaping (_ isSuccess: Bool, _ errorMsg: String?) -> Void) {
        MJAuthorization.requestAuth(type: .photoReadWrite) {
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = UUID().uuidString + ".mp4"
            let tempFileURL = tempDirectory.appendingPathComponent(fileName)
            do {
                // 将数据写入临时文件
                try videoData.write(to: tempFileURL)
                
                // 保存视频到相册
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tempFileURL)
                }) { success, error in
                    // 删除临时文件
                    do {
                        try FileManager.default.removeItem(at: tempFileURL)
                    } catch {
                    }
                    //
                    DispatchQueue.main.async {
                        if success {
                            completion(true, nil)
                        } else {
                            let errorMsg = error?.localizedDescription ?? "unknown_error".mj_Localized()
                            completion(false, errorMsg)
                        }
                    }
                }
            } catch {
                let errorMsg = error.localizedDescription
                completion(false, errorMsg)
            }
        } failure: {
            // 无相册权限
            let errorMsg = "no_permission".mj_Localized()
            completion(false, errorMsg)
        }
    }
}

public extension ZLPicker {
    // MARK: - 获取视频第一帧图像
    /// 获取视频第一帧图像
    func getVideoFirstImage(index: Int = 0,
                            fileUrl: URL,
                            completed: @escaping ((_ index: Int, _ firstImage: UIImage) -> Void)) {
        // 创建 AVAsset
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        // 获取视频的第一帧
        let time = CMTime(seconds: 0, preferredTimescale: 600) // 第一帧
        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, image, _, result, error in
            if let error = error {
                print("==> Error generating image: \(error)")
                DispatchQueue.main.async {
                    completed(index, UIImage())
                }
                return
            }
            //
            if let image = image {
                DispatchQueue.main.async {
                    let firstImage = UIImage(cgImage: image)
                    completed(index, firstImage)
                }
            }
        }
    }
}

// MARK: -
public extension ZLPicker {
    private func getPhotoBrowserData(result: ZLResultModel,
                                     compeleted: @escaping ((_ data: MJSystemFileInfo) -> Void)) {
        if result.asset.mediaType == .video {
            // 视频
            processVideo(asset: result.asset) { fileData in
                compeleted(fileData)
            }
        } else {
            // 图片
            var fileData: MJSystemFileInfo = MJSystemFileInfo()
            fileData.id = String.randomIntString(length: 10)
            fileData.fileType = ".png"
            let dateStr = Date.dateToString(date: Date(), dateFormat: MJ.yyyyMMddHHmmss)
            fileData.fileName = String.randomString(length: 4) + "_" + dateStr + fileData.fileType
            if let data = result.image.pngData() {
                fileData.data = data
                compeleted(fileData)
            }
        }
    }
    
    /// PHAsset -> URL -> MFSystemFileInfo
    private func processVideo(asset: PHAsset,
                              compeleted: @escaping ((_ fileData: MJSystemFileInfo) -> Void)) {
        let options = PHVideoRequestOptions()
        // 获取原始视频数据
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, audioMix, info) in
            if let urlAsset = avAsset as? AVURLAsset {
                let videoURL = urlAsset.url
                let fileData = ZLPicker.shared.systemUrlToData(url: videoURL, isNeedAccessingSecurity: false)
                compeleted(fileData)
            }
        }
    }
    
    private func getAsset(from localIdentifier: String?) -> PHAsset? {
        guard let id = localIdentifier else {
            return nil
        }
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        if result.count > 0 {
            return result[0]
        }
        return nil
    }
}
