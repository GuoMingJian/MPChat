////
////  MJAudioPlayerManager.swift
////
////  Created by GuoMingJian on 2025/5/22.
////
//
//import UIKit
//import MobileVLCKit
//
//public let kAudioFolder = "MJ_Audios"
//
//class MJAudioPlayerManager: NSObject {
//    static let shared = MJAudioPlayerManager()
//    
//    private var mediaPlayer: VLCMediaPlayer?
//    private var didChangedTimeBlock: ((_ currentTime: Int, _ totalTime: Int) -> Void)?
//    private var didEndBlock: (() -> Void)?
//    
//    // MARK: - public
//    // MARK: 播放音频
//    public func play(filePath: String,
//                     didChangedTimeBlock: @escaping ((_ currentTime: Int, _ totalTime: Int) -> Void),
//                     didEndBlock: @escaping (() -> Void)) {
//        stop()
//        self.didChangedTimeBlock = didChangedTimeBlock
//        self.didEndBlock = didEndBlock
//        //
//        let url = URL(fileURLWithPath: filePath)
//        // 使用 MobileVLCKit 播放 opus 文件
//        mediaPlayer = VLCMediaPlayer()
//        mediaPlayer?.delegate = self
//        mediaPlayer?.media = VLCMedia(url: url)
//        mediaPlayer?.play()
//    }
//    
//    // MARK: 停止播放
//    public func stop() {
//        // 停止 VLCMediaPlayer
//        if let mediaPlayer = mediaPlayer {
//            mediaPlayer.stop()
//            mediaPlayer.delegate = nil
//            self.mediaPlayer = nil
//        }
//        self.didChangedTimeBlock = nil
//        self.didEndBlock = nil
//    }
//    
//    // MARK: 获取音频文件总时长
//    /// 获取音频文件总时长
//    public func getAudioInfo(fileUrl: String,
//                             saveFileName: String,
//                             index: Int,
//                             success: @escaping ((_ audioSavePath: String, _ audioTotalTime: Int, _ index: Int) -> Void),
//                             fail: @escaping (() -> Void)) {
//        guard let url = URL(string: fileUrl) else {
//            print("==> Invalid URL: \(fileUrl)")
//            fail()
//            return
//        }
//        
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let data = data {
//                // 创建文件来保存opus/mp3音频数据
//                self.createAudioDirectory { folderPath in
//                    let fileType = fileUrl.contains(".opus") ? ".opus" : ".mp3"
//                    let tempFilePath = "\(folderPath)/\(saveFileName)\(fileType)"
//                    FileManager.default.createFile(atPath: tempFilePath, contents: data, attributes: nil)
//                    // 计算音频总时长
//                    self.getAudioDuration(filePath: tempFilePath) { duration in
//                        success(tempFilePath, duration, index)
//                    } fail: {
//                        fail()
//                    }
//                } fail: {
//                    fail()
//                }
//            } else {
//                print("==> Error downloading file: \(error?.localizedDescription ?? "Unknown error")")
//                fail()
//            }
//        }
//        task.resume()
//    }
//    
//    // MARK: - private
//    private func getAudioDuration(filePath: String,
//                                  success: @escaping (Int) -> Void,
//                                  fail: @escaping () -> Void) {
//        let url = URL(fileURLWithPath: filePath)
//        // 使用 MobileVLCKit 获取时长
//        let mediaPlayer = VLCMediaPlayer()
//        mediaPlayer.media = VLCMedia(url: url)
//        mediaPlayer.play()
//        // 设置静音
//        mediaPlayer.audio?.volume = 0
//        // 等待一段时间以确保时长可用
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            if mediaPlayer.media?.length.intValue ?? 0 > 0 {
//                // 转换为秒
//                let duration = Int(Double(mediaPlayer.media?.length.intValue ?? 0) / 1000.0)
//                success(duration)
//            } else {
//                fail()
//            }
//            mediaPlayer.stop()
//        }
//    }
//    
//    private func createAudioDirectory(success: @escaping ((_ path: String) -> Void),
//                                      fail: @escaping (() -> Void)) {
//        let audioDirectory = NSTemporaryDirectory().appending(kAudioFolder)
//        let fileManager = FileManager.default
//        if !fileManager.fileExists(atPath: audioDirectory) {
//            do {
//                try fileManager.createDirectory(atPath: audioDirectory, withIntermediateDirectories: true, attributes: nil)
//                success(audioDirectory)
//            } catch {
//                fail()
//            }
//        } else {
//            // 已存在
//            success(audioDirectory)
//        }
//    }
//}
//
//// MARK: - 删除缓存文件夹的所有音频文件
//extension MJAudioPlayerManager {
//    /// 删除 MJ_Audios 音频文件
//    static func deleteAllFilesInAudioDirectory() {
//        let audioDirectory = NSTemporaryDirectory().appending(kAudioFolder)
//        let fileManager = FileManager.default
//        do {
//            let files = try fileManager.contentsOfDirectory(atPath: audioDirectory)
//            for file in files {
//                let filePath = audioDirectory.appending("/\(file)")
//                try fileManager.removeItem(atPath: filePath)
//                print("删除\(kAudioFolder)/\(file)")
//            }
//            print("==> All files deleted in \(audioDirectory)")
//        } catch {
//            print("==> Error deleting files: \(error)")
//        }
//    }
//    
//    /// 秒格式化 xx:xx (100s -> 01:40)
//    static func getTimeString(time: Int) -> String {
//        let min = time / 60
//        let minStr = String(format: "%02d", min)
//        let second = time - min * 60
//        let secondStr = String(format: "%02d", second)
//        return "\(minStr):\(secondStr)"
//    }
//}
//
//// MARK: - VLCMediaPlayerDelegate
//extension MJAudioPlayerManager: VLCMediaPlayerDelegate {
//    func mediaPlayerStateChanged(_ aNotification: Notification) {
//        guard let mediaPlayer = aNotification.object as? VLCMediaPlayer else { return }
//        if mediaPlayer.state == .ended {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//                guard let self = self else { return }
//                //
//                if let block = self.didEndBlock {
//                    block()
//                }
//            }
//        }
//    }
//    
//    func mediaPlayerTimeChanged(_ aNotification: Notification) {
//        guard let mediaPlayer = aNotification.object as? VLCMediaPlayer else { return }
//        let currentTime = mediaPlayer.time.intValue / 1000
//        let totalTime = (mediaPlayer.media?.length.intValue ?? 0) / 1000
//        /// 当前时间
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            if let block = self.didChangedTimeBlock {
//                block(Int(currentTime), Int(totalTime))
//            }
//        }
//    }
//}
