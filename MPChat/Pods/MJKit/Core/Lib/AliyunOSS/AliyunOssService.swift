//
//  AliyunOssService.swift
//  MJKit
//
//  Created by 郭明健 on 2025/12/3.
//

import UIKit

@objcMembers
public class OssImageData: NSObject {
    public var url: String = ""
    public var imageData: Data = Data()
    public var fileUrl: URL?
    
    public override init() {
        super.init()
    }
    
    @objc
    public init(url: String,
                imageData: Data) {
        self.url = url
        self.imageData = imageData
        super.init()
    }
}

@objcMembers
public class OssDownloadResult: NSObject {
    public var url: String = ""
    public var data: Data = Data()
    
    public override init() {
        super.init()
    }
    
    @objc
    public init(url: String, data: Data) {
        self.url = url
        self.data = data
        super.init()
    }
}

@objcMembers
public class AliyunOssService: NSObject {
    public static let shared = AliyunOssService()
    
    public var lastUploadData: OssUploadData = OssUploadData()
    
    private override init() {
        super.init()
    }
    
    @objc(uploadImages:success:fail:)
    public func uploadImages(images: [OssImageData],
                             success: @escaping ((_ urls: [String]) -> Void),
                             fail: @escaping ((Error) -> Void)) {
        requestOssConfig(success: { ossConfig in
            var ossDataList: [OssUploadData] = []
            for (_, item) in images.enumerated() {
                let uploadData = OssUploadData()
                uploadData.tAccessKey = ossConfig.tAccessKey
                uploadData.tSecretKey = ossConfig.tSecretKey
                uploadData.tToken = ossConfig.tToken
                uploadData.expirationTimeInGMTFormat = ossConfig.expirationTimeInGMTFormat
                uploadData.expiration = ossConfig.expiration
                uploadData.endpoint = ossConfig.endpoint
                uploadData.bucketName = ossConfig.bucketName
                //
                uploadData.fileName = item.url
                uploadData.fileData = item.imageData
                uploadData.fileUrl = item.fileUrl
                ossDataList.append(uploadData)
            }
            //
            AliyunOssManager.shared.uploadDataListToOSS(dataList: ossDataList, success: success, fail: fail)
        }, fail: fail)
    }
    
    /// 异步上传图片
    public func uploadImages(images: [OssImageData]) async throws -> [String] {
        return try await withCheckedThrowingContinuation { continuation in
            self.uploadImages(images: images) { urls in
                continuation.resume(returning: urls)
            } fail: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - 下载文件（单个）
    @objc(downloadWithUrl:success:fail:)
    public func download(with url: String,
                         success: @escaping ((_ result: OssDownloadResult) -> Void),
                         fail: @escaping ((Error) -> Void)) {
        requestOssConfig(success: { ossConfig in
            let uploadData = OssUploadData()
            uploadData.tAccessKey = ossConfig.tAccessKey
            uploadData.tSecretKey = ossConfig.tSecretKey
            uploadData.tToken = ossConfig.tToken
            uploadData.expirationTimeInGMTFormat = ossConfig.expirationTimeInGMTFormat
            uploadData.endpoint = ossConfig.endpoint
            uploadData.bucketName = ossConfig.bucketName
            uploadData.fileName = url
            
            AliyunOssManager.shared.download(data: uploadData,
                                             downloadProgress: nil,
                                             success: { data in
                let result = OssDownloadResult(url: url, data: data)
                success(result)
            }, fail: fail)
        }, fail: fail)
    }
    
    // MARK: -
    @objc
    public func requestOssConfig(success: @escaping ((_ ossData: OssUploadData) -> Void),
                                 fail: @escaping ((Error) -> Void)) {
        let currentTimeStamp = Date().msTimeStamp.toInt()
        let expirationTimeStamp = AliyunOssService.shared.lastUploadData.expiration
        if currentTimeStamp > expirationTimeStamp {
            // oss权限过期，重新请求
            //            BaseAPI.getNewOssConfig { result in
            //                if let response = try? result.get(),
            //                   response.ossObjects.isEmpty.negated,
            //                   let obj = response.ossObjects.first {
            //                    let uploadData = OssUploadData()
            //                    uploadData.tAccessKey = obj.accessKeyID
            //                    uploadData.tSecretKey = obj.accessKeySecret
            //                    uploadData.tToken = obj.securityToken
            //                    uploadData.expirationTimeInGMTFormat = obj.expireTime
            //                    uploadData.expiration = obj.expiration
            //                    uploadData.endpoint = obj.endpoint
            //                    uploadData.bucketName = obj.baseFile
            //                    //
            //                    AliyunOssService.shared.lastUploadData = uploadData
            //                    success(uploadData)
            //                } else {
            //                    let error = NSError(domain: "AliyunOssService",
            //                                        code: -1,
            //                                        userInfo: [NSLocalizedDescriptionKey: "Get OSS Fail!"])
            //                    fail(error)
            //                }
            //            }
        } else {
            success(AliyunOssService.shared.lastUploadData)
        }
    }
}

extension AliyunOssService {
    /// 根据图片后缀拼接完整的OSS图片Url
    @objc(getOssCompletionUrl:)
    public func getOssCompletionUrl(url: String) -> String {
        var imageUrl = url
        if !url.contains("https://") {
            imageUrl = "https://mp-basefile-sg.oss-accelerate.aliyuncs.com/\(url)"
        }
        return imageUrl
    }
}
