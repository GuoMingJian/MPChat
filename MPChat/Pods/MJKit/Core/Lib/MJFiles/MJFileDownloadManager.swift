//
//  MJFileDownloadManager.swift
//
//  Created by 郭明健 on 2025/5/15.
//

import UIKit

public class MJFileDownloadManager: NSObject {
    static let shared = MJFileDownloadManager()
    
    private var downloadSuccessBlock: ((_ saveUrl: URL, _ isAlreadyExists: Bool) -> Void)?
    private var downloadFailBlock: ((_ error: Error?) -> Void)?
    private var downloadProgressBlock: ((_ progress: Float) -> Void)?
    //
    private var savedUrl: URL?
    private let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    private var currentVC: UIViewController = UIViewController()
    
    // MARK: - public
    public func downloadFile(saveFileName: String,
                             fileUrl: String,
                             successBlock: ((_ saveUrl: URL, _ isAlreadyExists: Bool) -> Void)? = nil,
                             failBlock: ((_ error: Error?) -> Void)? = nil,
                             progressBlock: ((_ progress: Float) -> Void)? = nil) {
        let saveURL: URL? = documentPath?.appendingPathComponent(saveFileName)
        let fileManager = FileManager.default
        if let saveURL = saveURL {
            if fileManager.fileExists(atPath: saveURL.path) {
                // 已存在文件
                successBlock?(saveURL, true)
            } else {
                self.savedUrl = saveURL
                // 不存在，下载文件
                self.downloadSuccessBlock = successBlock
                self.downloadFailBlock = failBlock
                self.downloadProgressBlock = progressBlock
                //
                beginDownload(fileUrl: fileUrl)
            }
        }
    }
    
    public func openFile(filePath: String,
                         currentVC: UIViewController) {
        self.currentVC = currentVC
        let documentVC = UIDocumentInteractionController(url: URL(fileURLWithPath: filePath))
        documentVC.delegate = self
        documentVC.presentPreview(animated: true)
    }
    
    // MARK: - private
    private func beginDownload(fileUrl: String) {
        guard let fileURL = URL(string: fileUrl) else { return }
        // 创建URLSession对象
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        // 创建下载任务
        let downloadTask = session.downloadTask(with: fileURL)
        downloadTask.resume()
    }
    
    private func resetBlock() {
        self.downloadSuccessBlock = nil
        self.downloadProgressBlock = nil
        self.downloadFailBlock = nil
    }
}

// MARK: - URLSessionDownloadDelegate
extension MJFileDownloadManager: URLSessionDownloadDelegate {
    // 下载完成
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //
        do {
            // 移动下载完成的文件到目标位置
            try FileManager.default.moveItem(at: location, to: self.savedUrl!)
            // print("==> 文件下载完成，存储位置:\(self.savedUrl?.path ?? "")")
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let block = self.downloadSuccessBlock {
                    block(self.savedUrl!, false)
                }
                self.resetBlock()
            }
        } catch {
            DispatchQueue.main.async {
                print("==> 下载文件，文件移动失败！")
            }
        }
    }
    
    // 下载进度
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            // print("==> 文件下载进度:\(progress * 100)%")
            if let block = self.downloadProgressBlock {
                block(progress)
            }
        }
    }
    
    // 下载失败
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let block = self.downloadFailBlock {
                block(error)
            }
            self.resetBlock()
        }
    }
}

// MARK: - UIDocumentInteractionControllerDelegate
extension MJFileDownloadManager: UIDocumentInteractionControllerDelegate {
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self.currentVC
    }
    
    public func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        // 关闭预览时的处理逻辑
    }
}
