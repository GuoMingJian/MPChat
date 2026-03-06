
import UIKit
import HXPhotoPicker

public class HXBrowser {
    public static func show(
        mediaResults: [MediaSelectionResult],
        currentIndex: Int = 0,
        fromViewController: UIViewController? = nil,
        transitionImage: UIImage? = nil,
        deleteHandler: ((Int) -> Void)? = nil
    ) {
        var config = PhotoBrowser.Configuration()
        config.showDelete = deleteHandler != nil
        config.backgroundColor = .black
        config.modalPresentationStyle = .custom
        
        let browser = PhotoBrowser(
            config,
            pageIndex: currentIndex,
            transitionalImage: transitionImage
        )
        
        browser.numberOfPages = {
            return mediaResults.count
        }
        
        browser.assetForIndex = { index in
            if index < mediaResults.count {
                let result = mediaResults[index]
                if result.isNetworkResource, let url = result.url {
                    if result.fileType == .image {
                        let networkImageAsset = NetworkImageAsset(
                            thumbnailURL: url,
                            originalURL: url
                        )
                        return PhotoAsset.init(networkImageAsset: networkImageAsset)
                    } else if result.fileType == .video {
                        let networkVideoAsset = NetworkVideoAsset(
                            networkVideo: url
                        )
                        return PhotoAsset.init(networkVideoAsset: networkVideoAsset)
                    }
                }
                
                if result.fileType == .image, let image = result.image {
                    return PhotoAsset.init(image: image)
                } else if result.fileType == .video, let path = result.path {
                    let localVideoAsset = LocalVideoAsset(videoURL: URL(fileURLWithPath: path))
                    return PhotoAsset.init(localVideoAsset: localVideoAsset)
                }
            }
            return PhotoAsset(image: UIImage())
        }
        
        if let deleteHandler = deleteHandler {
            browser.deleteAssetHandler = { index, asset, browser in
                deleteHandler(index)
            }
        }
        
        browser.show(fromViewController)
    }
}
