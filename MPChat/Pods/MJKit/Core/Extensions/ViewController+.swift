
import UIKit

public extension UIApplication {
    static var rootViewController: UIViewController? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController
    }
}

public extension UIViewController {
    static var currentlyVisible: UIViewController {
        guard let viewController = findCurrentViewController(from: UIApplication.rootViewController) else {
            assertionFailure("⚠️ Unable to find current UIViewController")
            return UIViewController()
        }
        return viewController
    }
    
    static func findCurrentViewController(from baseViewController: UIViewController? = UIApplication.rootViewController) -> UIViewController? {
        
        if let navigationController = baseViewController as? UINavigationController {
            return findCurrentViewController(from: navigationController.visibleViewController)
        }
        
        if let tabBarController = baseViewController as? UITabBarController {
            return findCurrentViewController(from: tabBarController.selectedViewController)
        }
        
        if let presentedViewController = baseViewController?.presentedViewController {
            return findCurrentViewController(from: presentedViewController)
        }
        
        return baseViewController
    }
}

public extension UIView {
    var parentViewController: UIViewController? {
        var nextResponder: UIResponder? = self
        while let responder = nextResponder {
            if let vc = responder as? UIViewController {
                return vc
            }
            nextResponder = responder.next
        }
        return nil
    }
}
