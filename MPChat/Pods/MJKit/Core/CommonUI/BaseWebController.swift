import UIKit
import WebKit

public class BaseWebViewController: UIViewController {
    let url: String
    let navTitle: String?
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        
        // 启用 JavaScript
        if #available(iOS 14.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        // 允许 Cookie 和本地存储
        config.websiteDataStore = .default()
        
        // 设置桌面版 User-Agent 以提高兼容性
        let desktopUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        
        let view = WKWebView(frame: .zero, configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.navigationDelegate = self
        view.uiDelegate = self
        
        // 设置自定义 User-Agent
        view.customUserAgent = desktopUserAgent
        
        // 启用手势和预览
        view.allowsBackForwardNavigationGestures = true
        view.allowsLinkPreview = true
        
        return view
    }()
    
    // 返回按钮
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // 标题 Label
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .darkText
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.text = navTitle ?? ""
        return label
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .systemBlue
        view.trackTintColor = .clear
        view.isHidden = true
        return view
    }()
    
    private lazy var reloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("load_fail_try_again".mj_Localized(), for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(reloadAction), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private var observation: NSKeyValueObservation?
    
    public init(url: String,
                title: String? = nil) {
        self.url = url
        self.navTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        observation?.invalidate()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupProgressObserver()
        loadWebContent()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.stopLoading()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(webView)
        view.addSubview(progressView)
        view.addSubview(reloadButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            
            webView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            progressView.topAnchor.constraint(equalTo: webView.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),
            
            reloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reloadButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60)
        ])
    }
    
    private func setupProgressObserver() {
        // 监听加载进度
        observation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
            guard let self = self, let progress = change.newValue else { return }
            self.updateProgress(progress)
        }
    }
    
    private func loadWebContent() {
        guard let url = URL(string: self.url) else {
            showErrorAlert(message: "无效的 URL")
            return
        }
        
        var request = URLRequest(url: url)
        
        // 设置通用的请求头以提高兼容性
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        
        webView.load(request)
    }
    
    private func updateProgress(_ progress: Double) {
        progressView.isHidden = false
        progressView.setProgress(Float(progress), animated: true)
        
        if progress >= 1.0 {
            UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
                self.progressView.alpha = 0
            }) { _ in
                self.progressView.isHidden = true
                self.progressView.progress = 0
                self.progressView.alpha = 1
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "加载失败",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Button Actions
    
    @objc private func reloadAction() {
        reloadButton.isHidden = true
        webView.reload()
    }
    
    @objc private func backButtonTapped() {
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    public func reload() {
        webView.reload()
    }
    
    private func handleWebViewError(_ error: Error) {
        let nsError = error as NSError
        
        // 忽略取消的请求
        if nsError.code == NSURLErrorCancelled {
            return
        }
        
        print("WebView加载失败: \(error.localizedDescription)")
        print("错误代码: \(nsError.code)")
        print("错误域: \(nsError.domain)")
        
        // 显示重试按钮
        reloadButton.isHidden = false
        progressView.isHidden = true
        progressView.progress = 0
    }
}

// MARK: - WKNavigationDelegate
extension BaseWebViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
        reloadButton.isHidden = true
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
        progressView.progress = 0
        
        // 如果初始化时没有设置标题，使用网页标题更新 Label
        if navTitle == nil || navTitle?.isEmpty == true {
            titleLabel.text = webView.title ?? ""
        }
        
        reloadButton.isHidden = true
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleWebViewError(error)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleWebViewError(error)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        let scheme = url.scheme?.lowercased() ?? ""
        
        // 允许的协议
        let allowedSchemes = ["http", "https", "file", "about", "data"]
        let isAllowedScheme = allowedSchemes.contains { scheme.hasPrefix($0) }
        
        // 处理非 HTTP 协议
        if !isAllowedScheme {
            print("拦截非HTTP协议: \(scheme)")
            
            // 检查是否可以外部打开
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if !success {
                        print("无法打开URL: \(url)")
                    }
                }
            } else {
                print("没有应用可以处理此URL: \(url)")
            }
            
            decisionHandler(.cancel)
            return
        }
        
        // 处理 target="_blank"
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate
extension BaseWebViewController: WKUIDelegate {
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // 处理新窗口打开
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
