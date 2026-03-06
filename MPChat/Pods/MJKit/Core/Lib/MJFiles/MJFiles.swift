//
//  MJFiles.swift
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

// MARK: -
public class MJFiles {
    enum MJFileType: String {
        // 文本
        case txt = "txt"
        case rtf = "rtf"
        case csv = "csv"
        case md = "md"
        // Office
        case doc = "doc"
        case docx = "docx"
        case xlsx = "xlsx"
        case xls = "xls"
        case ppt = "ppt"
        case pptx = "pptx"
        // PDF
        case pdf = "pdf"
        // 图像
        case png = "png"
        case jpeg = "jpeg"
        case jpg = "jpg"
        case jpe = "jpe"
        case jpf = "jpf"
        case jpx = "jpx"
        case jp2 = "jp2"
        case j2c = "j2c"
        case j2k = "j2k"
        case jpc = "jpc"
        case gif = "gif"
        case bmp = "bmp"
        case rle = "rle"
        case dib = "dib"
        case iff = "iff"
        case tdi = "tdi"
        case webp = "webp"
        case tiff = "tiff"
        case tif = "tif"
        case svg = "svg"
        case heic = "heic"
        case heif = "heif"
        // 音频
        case mp3 = "mp3"
        case wav = "wav"
        case flac = "flac"
        case ogg = "ogg"
        case aac = "aac"
        case m4a = "m4c"
        case wma = "wma"
        case aiff = "aiff"
        case m4r = "m4r"
        // 视频
        case mp4 = "mp4"
        case avi = "avi"
        case mov = "mov"
        case mkv = "mkv"
        case wmv = "wmv"
        case flv = "flv"
        case mpeg = "mpeg"
        case threegp = "3gp"
        case webm = "webm"
        case mpg = "mpg"
        case dat = "dat"
        case divx = "divx"
        case xvid = "xvid"
        case rm = "rm"
        case rmvb = "rmvb"
        case qt = "qt"
        case asf = "asf"
        case vob = "vob"
        case avs = "avs"
        case ts = "ts"
        case ogm = "ogm"
        case nsv = "nsv"
        case swf = "swf"
        // 压缩和归档
        case zip = "zip"
        case rar = "rar"
        case tar = "tar"
        case gz = "gz"
        case sevenZ = "7z"
        // html
        case html = "html"
        case htm = "htm"
        case xml = "xml"
        // 数据和编程
        case json = "json"
        case js = "js"
        case css = "css"
        case py = "py"
        case java = "java"
        case c = "c"
        case cpp = "cpp"
        case swift = "swift"
        // 其它
        case plist = "plist"
        case sql = "sql"
        case db = "db"
        case sqlite = "sqlite"
        
        // 未知
        case unknown
        
        /// 获取特定类型的展示图
        public func getTypeImage() -> UIImage {
            var icon: UIImage?
            switch self {
            case .txt, .rtf, .csv, .md:
                icon = UIImage.mj_Image("mj_txt")
            case .ppt, .pptx:
                icon = UIImage.mj_Image("mj_ppt")
            case .xls, .xlsx:
                icon = UIImage.mj_Image("mj_xls")
            case .doc, .docx:
                icon = UIImage.mj_Image("mj_doc")
            case .pdf:
                icon = UIImage.mj_Image("mj_pdf")
            case .zip, .rar, .tar, .gz, .sevenZ:
                icon = UIImage.mj_Image("mj_zip")
            case .mp3, .wav, .flac, .ogg, .aac, .m4a, .wma, .aiff, .m4r:
                icon = UIImage.mj_Image("mj_mp3")
            case .mp4, .avi, .mov, .mkv, .wmv, .flv, .mpeg, .threegp, .webm, .mpg, .dat, .divx, .xvid, .rm, .rmvb, .qt, .asf, .vob, .avs, .ts, .ogm, .nsv, .swf:
                icon = UIImage.mj_Image("mj_video")
            default:
                icon = UIImage.mj_Image("mj_unknown")
                break
            }
            return icon ?? UIImage.mj_Image("mj_image_error")
        }
        
        /// 判断是否为图片类型
        public func isPhotoType() -> Bool {
            var isPhoto: Bool = false
            let photoList = MJFileType.photoTypeList()
            isPhoto = photoList.contains(self)
            return isPhoto
        }
        
        /// 判断是否为视频类型
        public func isVideoType() -> Bool {
            var result: Bool = false
            let list = MJFileType.videoTypeList()
            result = list.contains(self)
            return result
        }
        
        /// 判断是否为音频类型
        public func isAudioType() -> Bool {
            var result: Bool = false
            let list = MJFileType.musicTypeList()
            result = list.contains(self)
            return result
        }
        
        /// 获取图片类型集合
        static func photoTypeList() -> [MJFileType] {
            let photoList: [MJFileType] = [.png, .jpeg, .jpg, .jpe, .jpf, .jpx, .jp2, .j2c, .j2k, .jpc, .gif, .bmp, .rle, .dib, .iff, .tdi, .webp, .tiff, .tif, .svg, .heic, .heif]
            return photoList
        }
        
        /// 获取视频类型集合
        static func videoTypeList() -> [MJFileType] {
            let videoList: [MJFileType] = [.mp4, .avi, .mov, .mkv, .wmv, .flv, .mpeg, .threegp, .webm, .mpg, .dat, .divx, .xvid, .rm, .rmvb, .qt, .asf, .vob, .avs, .ts, .ogm, .nsv, .swf]
            return videoList
        }
        
        /// 获取音频类型集合
        static func musicTypeList() -> [MJFileType] {
            let musicList: [MJFileType] = [.mp3, .wav, .flac, .ogg, .aac, .m4a, .wma, .aiff, .m4r]
            return musicList
        }
    }
}
