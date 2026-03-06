
import UIKit
import Then

public class HUDManager {
    public struct Style {
        public static let toastDuration: TimeInterval = 2.0
        static let cornerRadius: CGFloat = 10
        static let maxTextWidth: CGFloat = 200
        static let toastTag = 5820
        static let animationDuration: TimeInterval = 0.25
        static let minLoadingHeight: CGFloat = 110
        static let backgroundTag = 1001
        static let minWidth: CGFloat = 110
        static let fontSize: CGFloat = 14
        static let padding: CGFloat = 15
        static let minHeight: CGFloat = 50
        static let loadingTag = 202515820
    }
    
    private static func makeHUDView(message: String, loading: Bool) -> UIView {
        let font = UIFont.systemFont(ofSize: Style.fontSize)
        let maxSize = CGSize(width: Style.maxTextWidth, height: .greatestFiniteMagnitude)
        let textSize = (message as NSString).boundingRect(
            with: maxSize,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        ).size
        
        let minWidth = Style.minWidth
        let minHeight = loading ? Style.minLoadingHeight : Style.minHeight
        let width = max(minWidth, textSize.width + Style.padding * 2)
        let extraHeight: CGFloat = loading ? 40 : 0
        let height = max(minHeight, textSize.height + Style.padding * 2 + extraHeight)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height)).then {
            $0.backgroundColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1.0)
            $0.layer.cornerRadius = Style.cornerRadius
            $0.clipsToBounds = true
            $0.alpha = 0.1
        }
        
        if loading {
            let indicator = UIActivityIndicatorView(style: .large).then {
                $0.color = UIColor.white
                $0.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                $0.startAnimating()
                $0.center = CGPoint(x: width / 2, y: height / 2 - (message.isEmpty ? 0 : 10))
            }
            view.addSubview(indicator)
        }
        
        let labelY = loading ? height - textSize.height - Style.padding : (height - textSize.height) / 2
        let label = UILabel(frame: CGRect(x: Style.padding, y: labelY, width: width - Style.padding * 2, height: textSize.height)).then {
            $0.text = message
            $0.textColor = UIColor.white
            $0.font = font
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        view.addSubview(label)
        
        return view
    }
    
    private static func removeHUDSubviews(from container: UIView, tag: Int) {
        container.subviews.filter { $0.tag == tag }.forEach { subview in
            UIView.animate(withDuration: Style.animationDuration, animations: {
                subview.alpha = 0
            }) { _ in
                subview.removeFromSuperview()
            }
        }
    }
}

extension HUDManager {
    public static func showToast(_ message: String, in view: UIView? = nil, duration: TimeInterval = Style.toastDuration) {
        guard !message.isEmpty else { return }
        let targetView = view ?? UIApplication.shared.windows.first { $0.isKeyWindow }
        guard let container = targetView else { return }
        
        removeHUDSubviews(from: container, tag: Style.toastTag)
        
        let toast = makeHUDView(message: message, loading: false).then {
            $0.tag = Style.toastTag
            $0.alpha = 0
        }
        
        container.addSubview(toast)
        toast.center = container.center
        
        UIView.animate(withDuration: Style.animationDuration) { toast.alpha = 1 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: Style.animationDuration, animations: {
                toast.alpha = 0
            }) { _ in
                toast.removeFromSuperview()
            }
        }
    }
    
    public static func showLoading(_ message: String = "", in view: UIView? = nil) {
        let targetView = view ?? UIApplication.shared.windows.first { $0.isKeyWindow }
        guard let container = targetView else { return }
        
        dismiss(from: container)
        
        let overlay = UIView(frame: container.bounds).then {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.05)
            $0.tag = Style.backgroundTag
        }
        container.addSubview(overlay)
        
        let loadingView = makeHUDView(message: message, loading: true).then {
            $0.tag = Style.loadingTag
            $0.alpha = 0
        }
        
        container.addSubview(loadingView)
        loadingView.center = container.center
        
        UIView.animate(withDuration: Style.animationDuration) {
            loadingView.alpha = 1
        }
    }
    
    public static func dismiss(from view: UIView? = nil) {
        let container = view ?? UIApplication.shared.windows.first { $0.isKeyWindow }
        guard let validView = container else { return }
        removeHUDSubviews(from: validView, tag: Style.loadingTag)
        removeHUDSubviews(from: validView, tag: Style.backgroundTag)
    }
}

public extension HUDManager {
    static func runWithLoading(message: String = "",
                               delay: TimeInterval = 0.25,
                               completion: (() -> Void)? = nil) {
        HUDManager.showLoading(message)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            HUDManager.dismiss()
            guard NetworkMonitor.shared.currentConnectivityStatus == .connected else {
                HUDManager.showToast("network_error".mj_Localized())
                return
            }
            completion?()
        }
    }
}
