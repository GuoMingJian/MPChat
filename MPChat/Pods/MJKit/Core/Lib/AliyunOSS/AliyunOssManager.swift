////
////  AliyunOssManager.swift
////  MJKit
////
////  Created by 郭明健 on 2025/12/3.
////
//
//import UIKit
//import AliyunOSSiOS
//
//// MARK: -
//@objcMembers
//public class OssUploadData: NSObject {
//    public var tAccessKey: String = ""
//    public var tSecretKey: String = ""
//    public var tToken: String = ""
//    public var expirationTimeInGMTFormat: String = ""
//    public var expiration: Int64 = 0
//    public var endpoint: String = ""
//    public var bucketName: String = ""
//    // 上传数据
//    public var fileName: String = ""
//    public var fileData: Data = Data()
//    public var fileUrl: URL?
//    
//    public override init() {
//        super.init()
//    }
//}
//
//// MARK: -
//@objcMembers
//public class AliyunOssManager: NSObject {
//    public static let shared = AliyunOssManager()
//    
//    private var ossClient: OSSClient?
//    private var uploadRequest: OSSPutObjectRequest?
//    private var deleteRequest: OSSDeleteObjectRequest?
//    private var downloadRequest: OSSGetObjectRequest?
//    
//    private let lock = NSLock()
//    
//    private override init() {
//        super.init()
//    }
//    
//    deinit {
//        cleanup()
//    }
//    
//    // MARK: - 清理资源
//    @objc
//    public func cleanup() {
//        lock.lock()
//        defer { lock.unlock() }
//        
//        // 取消所有请求
//        self.uploadRequest?.cancel()
//        self.deleteRequest?.cancel()
//        self.downloadRequest?.cancel()
//        
//        // 清理引用
//        self.uploadRequest = nil
//        self.deleteRequest = nil
//        self.downloadRequest = nil
//        self.ossClient = nil
//    }
//    
//    // MARK: - 初始化OSS客户端
//    private func getOrCreateOSSClient(with data: OssUploadData) -> OSSClient? {
//        lock.lock()
//        defer { lock.unlock() }
//        
//        // 检查是否有现有的 client
//        if let existingClient = ossClient {
//            return existingClient
//        }
//        
//        // 创建新的 OSSClient
//        let credential = OSSFederationCredentialProvider(federationTokenGetter: { () -> OSSFederationToken? in
//            let token = OSSFederationToken()
//            token.tAccessKey = data.tAccessKey
//            token.tSecretKey = data.tSecretKey
//            token.tToken = data.tToken
//            token.expirationTimeInGMTFormat = data.expirationTimeInGMTFormat
//            token.expirationTimeInMilliSecond = data.expiration
//            return token
//        })
//        
//        let endpoint = data.endpoint
//        let client = OSSClient(endpoint: endpoint, credentialProvider: credential)
//        self.ossClient = client
//        
//        return client
//    }
//    
//    // MARK: - 检查凭证是否过期
//    private func isCredentialExpired(for data: OssUploadData) -> Bool {
//        let currentTimeStamp = Int64(Date().msTimeStamp.toInt())
//        let expirationTimeStamp = data.expiration
//        return (expirationTimeStamp == 0) ? false : (currentTimeStamp > expirationTimeStamp)
//    }
//    
//    // MARK: - 单数据上传
//    @objc(uploadDataToOSSWithData:uploadProgress:success:fail:)
//    public func uploadDataToOSS(data: OssUploadData,
//                                uploadProgress: OSSNetworkingUploadProgressBlock? = nil,
//                                success: @escaping ((String) -> Void),
//                                fail: @escaping ((Error) -> Void)) {
//        
//        let successOnMain: (String) -> Void = { fileName in
//            DispatchQueue.main.async {
//                success(fileName)
//            }
//        }
//        
//        let failOnMain: (Error) -> Void = { error in
//            DispatchQueue.main.async {
//                fail(error)
//            }
//        }
//        
//        // 检查凭证是否过期
//        if isCredentialExpired(for: data) {
//            let error = NSError(domain: "AliyunOssManager",
//                                code: -2,
//                                userInfo: [NSLocalizedDescriptionKey: "OSS凭证已过期"])
//            failOnMain(error)
//            return
//        }
//        
//        guard let ossClient = getOrCreateOSSClient(with: data) else {
//            let error = NSError(domain: "AliyunOssManager",
//                                code: -1,
//                                userInfo: [NSLocalizedDescriptionKey: "无法创建OSS客户端"])
//            failOnMain(error)
//            return
//        }
//        
//        let uploadRequest = OSSPutObjectRequest()
//        uploadRequest.bucketName = data.bucketName
//        uploadRequest.objectKey = data.fileName
//        if data.fileData.count > 0 {
//            uploadRequest.uploadingData = data.fileData
//        } else {
//            if let fileUrl = data.fileUrl {
//                uploadRequest.uploadingFileURL = fileUrl
//            }
//        }
//        
//        if let uploadProgress = uploadProgress {
//            uploadRequest.uploadProgress = uploadProgress
//        }
//        
//        lock.lock()
//        self.uploadRequest = uploadRequest
//        lock.unlock()
//        
//        let uploadTask = ossClient.putObject(uploadRequest)
//        uploadTask.continue({ [weak self] task -> Any? in
//            guard let self = self else { return nil }
//            
//            // 请求完成后清理引用
//            self.lock.lock()
//            if self.uploadRequest === uploadRequest {
//                self.uploadRequest = nil
//            }
//            self.lock.unlock()
//            
//            if let error = task.error {
//                print("上传失败: \(data.fileName), error: \(error)")
//                failOnMain(error)
//            } else {
//                print("上传成功: \(data.fileName)")
//                successOnMain(data.fileName)
//            }
//            return nil
//        })
//    }
//    
//    // MARK: - 多数据上传
//    @objc(uploadDataListToOSSWithData:success:fail:)
//    public func uploadDataListToOSS(dataList: [OssUploadData],
//                                    success: @escaping (([String]) -> Void),
//                                    fail: @escaping ((Error) -> Void)) {
//        
//        guard !dataList.isEmpty else {
//            let error = NSError(domain: "AliyunOssManager",
//                                code: -1,
//                                userInfo: [NSLocalizedDescriptionKey: "上传数据为空"])
//            DispatchQueue.main.async { fail(error) }
//            return
//        }
//        
//        var successfulFiles: [String] = []
//        var currentIndex = 0
//        
//        func uploadNext() {
//            guard currentIndex < dataList.count else {
//                // 所有数据都上传成功
//                DispatchQueue.main.async {
//                    success(successfulFiles)
//                }
//                return
//            }
//            
//            let currentData = dataList[currentIndex]
//            
//            // 调用单张上传
//            self.uploadDataToOSS(data: currentData,
//                                 uploadProgress: nil,
//                                 success: { fileName in
//                successfulFiles.append(fileName)
//                currentIndex += 1
//                uploadNext()
//            }, fail: fail)
//        }
//        
//        // 开始上传队列
//        uploadNext()
//    }
//    
//    // MARK: - 删除方法
//    @objc(deleteWithData:success:fail:)
//    public func delete(data: OssUploadData,
//                       success: @escaping (() -> Void),
//                       fail: @escaping ((Error) -> Void)) {
//        
//        let successOnMain: () -> Void = {
//            DispatchQueue.main.async {
//                success()
//            }
//        }
//        
//        let failOnMain: (Error) -> Void = { error in
//            DispatchQueue.main.async {
//                fail(error)
//            }
//        }
//        
//        // 检查凭证是否过期
//        if isCredentialExpired(for: data) {
//            let error = NSError(domain: "AliyunOssManager",
//                                code: -2,
//                                userInfo: [NSLocalizedDescriptionKey: "OSS凭证已过期"])
//            failOnMain(error)
//            return
//        }
//        
//        guard let ossClient = getOrCreateOSSClient(with: data) else {
//            let error = NSError(domain: "AliyunOssManager",
//                                code: -1,
//                                userInfo: [NSLocalizedDescriptionKey: "无法创建OSS客户端"])
//            failOnMain(error)
//            return
//        }
//        
//        let deleteRequest = OSSDeleteObjectRequest()
//        deleteRequest.bucketName = data.bucketName
//        deleteRequest.objectKey = data.fileName
//        
//        lock.lock()
//        self.deleteRequest = deleteRequest
//        lock.unlock()
//        
//        let deleteTask = ossClient.deleteObject(deleteRequest)
//        deleteTask.continue({ [weak self] task -> Any? in
//            guard let self = self else { return nil }
//            
//            // 请求完成后清理引用
//            self.lock.lock()
//            if self.deleteRequest === deleteRequest {
//                self.deleteRequest = nil
//            }
//            self.lock.unlock()
//            
//            if let error = task.error {
//                failOnMain(error)
//            } else {
//                successOnMain()
//            }
//            return nil
//        })
//    }
//    
//    // MARK: - 下载文件
//    @objc(downloadWithData:downloadProgress:success:fail:)
//    public func download(data: OssUploadData,
//                         downloadProgress: OSSNetworkingDownloadProgressBlock? = nil,
//                         success: @escaping ((Data) -> Void),
//                         fail: @escaping ((Error) -> Void)) {
//        
//        let successOnMain: (Data) -> Void = { downloadedData in
//            DispatchQueue.main.async {
//                success(downloadedData)
//            }
//        }
//        
//        let failOnMain: (Error) -> Void = { error in
//            DispatchQueue.main.async {
//                fail(error)
//            }
//        }
//        
//        if isCredentialExpired(for: data) {
//            print("OSS凭证已过期，需要重新获取")
//            let error = NSError(domain: "AliyunOssManager",
//                                code: -2,
//                                userInfo: [NSLocalizedDescriptionKey: "OSS凭证已过期，请重新获取"])
//            failOnMain(error)
//            
//            lock.lock()
//            self.ossClient = nil
//            lock.unlock()
//            
//            return
//        }
//        
//        guard let ossClient = getOrCreateOSSClient(with: data) else {
//            let error = NSError(domain: "AliyunOssManager",
//                                code: -1,
//                                userInfo: [NSLocalizedDescriptionKey: "无法创建OSS客户端"])
//            failOnMain(error)
//            return
//        }
//        
//        let downloadRequest = OSSGetObjectRequest()
//        downloadRequest.bucketName = data.bucketName
//        downloadRequest.objectKey = data.fileName
//        
//        if let downloadProgress = downloadProgress {
//            downloadRequest.downloadProgress = downloadProgress
//        }
//        
//        lock.lock()
//        self.downloadRequest = downloadRequest
//        lock.unlock()
//        
//        let downloadTask = ossClient.getObject(downloadRequest)
//        downloadTask.continue({ [weak self] task -> Any? in
//            guard let self = self else { return nil }
//            
//            // 请求完成后清理引用
//            self.lock.lock()
//            if self.downloadRequest === downloadRequest {
//                self.downloadRequest = nil
//            }
//            self.lock.unlock()
//            
//            if let error = task.error {
//                let errorMessage = error.localizedDescription.lowercased()
//                if errorMessage.contains("session") && errorMessage.contains("invalid") {
//                    print("检测到 session 无效错误，清理 OSSClient: \(data.fileName)")
//                    
//                    self.lock.lock()
//                    self.ossClient = nil
//                    self.lock.unlock()
//                }
//                
//                print("download oss image fail:[\(data.fileName)], error: \(error)")
//                failOnMain(error)
//            } else if let result = task.result as? OSSGetObjectResult,
//                      let data = result.downloadedData {
//                //print("download oss image success")
//                successOnMain(data)
//            } else {
//                let error = NSError(domain: "AliyunOssManager",
//                                    code: -1,
//                                    userInfo: [NSLocalizedDescriptionKey: "下载数据为空"])
//                failOnMain(error)
//            }
//            return nil
//        })
//    }
//    
//    // MARK: - 取消当前操作
//    @objc
//    public func cancel() {
//        lock.lock()
//        defer { lock.unlock() }
//        
//        self.uploadRequest?.cancel()
//        self.deleteRequest?.cancel()
//        self.downloadRequest?.cancel()
//        
//        self.uploadRequest = nil
//        self.deleteRequest = nil
//        self.downloadRequest = nil
//    }
//    
//    // MARK: - 取消特定下载
//    @objc(cancelDownloadForFileName:)
//    public func cancelDownload(forFileName fileName: String) {
//        lock.lock()
//        if let downloadRequest = self.downloadRequest,
//           downloadRequest.objectKey == fileName {
//            downloadRequest.cancel()
//            self.downloadRequest = nil
//        }
//        lock.unlock()
//    }
//}
