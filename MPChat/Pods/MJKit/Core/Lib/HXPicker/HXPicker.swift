
import UIKit
import Foundation
import Photos
import HXPhotoPicker

/*
 Task {
     // 打开相册
     Task {
         let config = HXPickerConfiguration(
             maxImageCount: 9,
             maxVideoCount: 1
         )
         let results = await HXPicker.shared.selectMedia(from: self, selectedAssetArray: mediaList, configuration: config)
         self.mediaList = results
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
             HXBrowser.show(mediaResults: results)
         })
     }
 }
 // 打开相机
 Task {
     if let result = await HXPicker.shared.openCamera(from: self, captureType: .all) {
         self.mediaList = [result]
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
             HXBrowser.show(mediaResults: results)
         })
     }
 }
 */

public enum MediaFileType {
    case image
    case video
}

public enum ShootType{
    case photo
    case video
    case all
}

public struct MediaSelectionResult {
    public let fileType: MediaFileType
    public let image: UIImage?
    public let path: String?
    public let phAsset: PHAsset?
    public let url: URL?
    public let coverUrl: URL?
    
    public init(fileType: MediaFileType, image: UIImage? = nil, path: String? = nil, phAsset: PHAsset? = nil, url: URL? = nil, coverUrl: URL? = nil) {
        self.fileType = fileType
        self.image = image
        self.path = path
        self.phAsset = phAsset
        self.url = url
        self.coverUrl = coverUrl
    }
    
    public var isNetworkResource: Bool {
        return url != nil && (url?.scheme == "http" || url?.scheme == "https")
    }
    
    public var isLocalResource: Bool {
        return path != nil || phAsset != nil
    }
}

public struct HXPickerConfiguration {
    public let maxImageCount: Int
    public let maxVideoCount: Int
    public let allowedFileTypes: Set<MediaFileType>
    public let allowMixedSelection: Bool
    public let enableAvatarEditing: Bool
    public let themeColor: UIColor
    
    public init(
        maxImageCount: Int = 6,
        maxVideoCount: Int = 1,
        allowedFileTypes: Set<MediaFileType> = [.image, .video],
        allowMixedSelection: Bool = true,
        enableAvatarEditing: Bool = false,
        themeColor: UIColor = UIColor.hexColor(color: "#DD000F") // 默认红色主题
    ) {
        self.maxImageCount = maxImageCount
        self.maxVideoCount = maxVideoCount
        self.allowedFileTypes = allowedFileTypes
        self.allowMixedSelection = allowMixedSelection
        self.enableAvatarEditing = enableAvatarEditing
        self.themeColor = themeColor
    }
}

public class HXPicker {
    public static let shared = HXPicker()
    private init() {}
    
    private var currentDelegate: PhotoPickerDelegate?
    private var currentAssetArray: [MediaSelectionResult] = []
    
    @MainActor
    public func selectMedia(
        from viewController: UIViewController,
        selectedAssetArray: [MediaSelectionResult] = [],
        configuration: HXPickerConfiguration = HXPickerConfiguration()
    ) async -> [MediaSelectionResult] {
        currentAssetArray = selectedAssetArray
        
        return await withCheckedContinuation { continuation in
            
            var pickerConfig = PickerConfiguration()
            if configuration.allowedFileTypes.contains(.image) && configuration.allowedFileTypes.contains(.video) {
                if configuration.allowMixedSelection {
                    pickerConfig.selectOptions = [.photo, .video]
                } else {
                    pickerConfig.selectOptions = [.photo]
                }
            } else if configuration.allowedFileTypes.contains(.image) {
                pickerConfig.selectOptions = [.photo]
            } else if configuration.allowedFileTypes.contains(.video) {
                pickerConfig.selectOptions = [.video]
            }
            
            pickerConfig.maximumSelectedCount = max(configuration.maxImageCount, configuration.maxVideoCount)
            pickerConfig.maximumSelectedPhotoCount = configuration.maxImageCount
            pickerConfig.maximumSelectedVideoCount = configuration.maxVideoCount
            pickerConfig.themeColor = configuration.themeColor
            pickerConfig.modalPresentationStyle = .fullScreen
            pickerConfig.languageType = .english
            pickerConfig.albumShowMode = .normal
            let photoPicker = PhotoPickerController(picker: pickerConfig)
            photoPicker.selectedAssetArray = selectedAssetArray.compactMap({
                PhotoAsset($0.phAsset ?? PHAsset())
            })
            
            let delegate = PhotoPickerDelegate { [weak self] results in
                Task {
                    guard let self = self else { return }
                    let mediaResults = await self.convertToMediaResults(results)
                    self.currentDelegate = nil
                    continuation.resume(returning: mediaResults)
                }
            } cancelHandler: { [weak self] in
                self?.currentDelegate = nil
                continuation.resume(returning: self?.currentAssetArray ?? [])
            }
            
            self.currentDelegate = delegate
            photoPicker.pickerDelegate = delegate
            viewController.present(photoPicker, animated: true)
        }
    }
    
    @MainActor
    public func selectAvatar(
        from viewController: UIViewController,
        enableEditing: Bool = true,
        configuration: HXPickerConfiguration = HXPickerConfiguration()
    ) async -> MediaSelectionResult? {
        
        return await withCheckedContinuation { continuation in
            var pickerConfig = PickerConfiguration()
            pickerConfig.selectOptions = [.photo]
            pickerConfig.selectMode = .single
            pickerConfig.themeColor = configuration.themeColor
            pickerConfig.modalPresentationStyle = .fullScreen
            pickerConfig.languageType = .english
            pickerConfig.albumShowMode = .normal
            
            if enableEditing {
                pickerConfig.photoList.finishSelectionAfterTakingPhoto = true
                pickerConfig.photoSelectionTapAction = .openEditor
                pickerConfig.editor.isFixedCropSizeState = true
                pickerConfig.editor.cropSize.aspectRatio = CGSize(width: 1, height: 1)
                pickerConfig.editor.cropSize.isResetToOriginal = false
                pickerConfig.editor.modalPresentationStyle = .fullScreen
            }
            
            let photoPicker = PhotoPickerController(picker: pickerConfig)
            let delegate = PhotoPickerDelegate { [weak self] results in
                Task {
                    guard let self = self else { return }
                    let mediaResults = await self.convertToMediaResults(results)
                    continuation.resume(returning: mediaResults.first)
                    self.currentDelegate = nil
                }
            } cancelHandler: { [weak self] in
                self?.currentDelegate = nil
                continuation.resume(returning: nil)
            }
            
            self.currentDelegate = delegate
            photoPicker.pickerDelegate = delegate
            viewController.present(photoPicker, animated: true)
        }
    }
    
    @MainActor
    public func openCamera(
        from viewController: UIViewController,
        captureType: ShootType = .all,
        configuration: HXPickerConfiguration = HXPickerConfiguration()
    ) async -> MediaSelectionResult? {
        
        return await withCheckedContinuation { (continuation: CheckedContinuation<MediaSelectionResult?, Never>) in
            var cameraConfig = CameraConfiguration()
            cameraConfig.isAutoBack = false
            cameraConfig.isSaveSystemAlbum = true
            cameraConfig.languageType = .english
            let cameraType: CameraController.CaptureType
            switch captureType {
            case .photo: cameraType = .photo
            case .video: cameraType = .video
            case .all:   cameraType = .all
            }
            
            let cameraController = CameraController(config: cameraConfig, type: cameraType)
            cameraController.modalPresentationStyle = .fullScreen
            let delegate = PhotoPickerDelegate { [weak cameraController] results in
                cameraController?.dismiss(animated: true) {
                    Task {
                        let mediaResults = await self.convertToMediaResults(results)
                        self.currentDelegate = nil
                        continuation.resume(returning: mediaResults.first)
                    }
                }
            } cancelHandler: { [weak cameraController] in
                cameraController?.dismiss(animated: true) {
                    self.currentDelegate = nil
                    continuation.resume(returning: nil)
                }
            }
            
            self.currentDelegate = delegate
            cameraController.cameraDelegate = delegate
            viewController.present(cameraController, animated: true)
        }
    }
    
    private func convertToMediaResults(_ results: [PhotoAsset]) async -> [MediaSelectionResult] {
        var mediaResults: [MediaSelectionResult] = []
        
        for result in results {
            let fileType: MediaFileType = result.mediaType == .photo ? .image : .video
            var image: UIImage?
            image = await withCheckedContinuation { continuation in
                result.getImage(targetSize: CGSize(width: 1024, height: 1024)) { img, _ in
                    continuation.resume(returning: img)
                }
            }
            var filePath: String?
            let urlResult = await withCheckedContinuation { continuation in
                result.getURL { urlResult in
                    continuation.resume(returning: urlResult)
                }
            }
            
            switch urlResult {
            case .success(let assetURLResult):
                filePath = assetURLResult.url.path
            case .failure:
                filePath = nil
            }
            
            let mediaResult = MediaSelectionResult(
                fileType: fileType,
                image: image,
                path: filePath,
                phAsset: result.phAsset
            )
            mediaResults.append(mediaResult)
        }
        return mediaResults
    }
}

private class PhotoPickerDelegate: NSObject, PhotoPickerControllerDelegate, CameraControllerDelegate{
    private let completionHandler: ([PhotoAsset]) -> Void
    private let cancelHandler: () -> Void
    
    init(completionHandler: @escaping ([PhotoAsset]) -> Void, cancelHandler: @escaping () -> Void) {
        self.completionHandler = completionHandler
        self.cancelHandler = cancelHandler
        super.init()
    }
    
    func pickerController(_ pickerController: PhotoPickerController, didFinishSelection result: PickerResult) {
        completionHandler(result.photoAssets)
    }
    
    func pickerController(didCancel pickerController: PhotoPickerController) {
        cancelHandler()
    }
    
    func cameraController(
        _ cameraController: CameraController,
        didFinishWithResult result: CameraController.Result,
        phAsset: PHAsset?,
        location: CLLocation?
    ) {
        guard let asset = phAsset else { return}
        completionHandler([PhotoAsset(asset: asset)])
    }
    
    func cameraController(didCancel cameraController: CameraController) {
        cancelHandler()
    }
}
