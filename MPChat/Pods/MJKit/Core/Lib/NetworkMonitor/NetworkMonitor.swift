
import Network
import Combine
import Network
import SystemConfiguration

/*
 // 使用：APPdelegate 添加 NetworkMonitor.shared.start() / stop() 方法
 
 private var cancellables = Set<AnyCancellable>()
 
 NetworkMonitor.shared.connectivityStatusPublisher
     .receive(on: DispatchQueue.main)
     .sink { [weak self] status in
         guard let self = self else { return }
         if status != .connected {
             print("---> 无网络！")
         } else {
             print("---> 有网络！")
         }
     }
     .store(in: &cancellables)
 */

public enum ConnectivityStatus: Equatable {
    case connected
    case disconnected
}

public final class NetworkMonitor {
    public static let shared = NetworkMonitor()
    
    public var connectivityStatusPublisher: AnyPublisher<ConnectivityStatus, Never> {
        connectivitySubject
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var currentConnectivityStatus: ConnectivityStatus {
        connectivitySubject.value
    }
    
    private let pathMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetMonitor")
    private let connectivitySubject = CurrentValueSubject<ConnectivityStatus, Never>(.disconnected)
    
    private init() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            let status: ConnectivityStatus = path.status == .satisfied ? .connected : .disconnected
            self?.connectivitySubject.send(status)
        }
    }
    
    public func start() {
        pathMonitor.start(queue: queue)
    }
    
    public func stop() {
        pathMonitor.cancel()
    }
    
    deinit {
        stop()
    }
}
