//import Network
//import Foundation
//
//@MainActor
//final class NetworkMonitor: ObservableObject {
//    static let shared = NetworkMonitor()
//    
//    private let monitor = NWPathMonitor()
//    // A API do NWPathMonitor ainda exige uma Queue para iniciar,
//    // mas ela fica isolada internamente e não vaza para a lógica do app.
//    private let queue = DispatchQueue(label: "Monitor")
//    
//    @Published private(set) var isConnected: Bool = false
//    @Published private(set) var isExpensive: Bool = false
//    
//    private init() {
//        monitor.pathUpdateHandler = { [weak self] path in
//            Task { @MainActor [weak self] in
//                self?.isConnected = path.status == .satisfied
//                self?.isExpensive = path.isExpensive
//            }
//        }
//        monitor.start(queue: queue)
//    }
//    
//    /// Retorna um Stream assíncrono para ser consumido via for-await-in
//    func statusStream() -> AsyncStream<Bool> {
//        AsyncStream { [weak self] continuation in
//            guard let `self` = self else { return }
//            // Envia valor inicial
//            continuation.yield(self.monitor.currentPath.status == .satisfied)
//            
//            monitor.pathUpdateHandler = { path in
//                let originalHandler = self.monitor.pathUpdateHandler
//                originalHandler?(path)
//                continuation.yield(path.status == .satisfied)
//            }
//        }
//    }
//}
import Network
import Foundation
import Combine

@MainActor
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.app.NetworkMonitor")
    
    // Usamos um CurrentValueSubject para que o monitor seja a "Fonte da Verdade" (Single Source of Truth)
    // Ele armazena o estado atual e notifica todos os interessados automaticamente.
    private let statusSubject = CurrentValueSubject<Bool, Never>(false)
    
    @Published private(set) var isConnected: Bool = false
    
    private init() {
        // Configuramos o handler APENAS UMA VEZ no init.
        monitor.pathUpdateHandler = { [weak self] path in
            let status = path.status == .satisfied
            
            // Atualiza o Subject (para o Stream) e a propriedade @Published (para a UI)
            Task { @MainActor in
                self?.isConnected = status
                self?.statusSubject.send(status)
            }
        }
        // Assim que o app abre, o sensor começa a trabalhar
        // em uma "fila" separada (queue) para não travar a tela.
        monitor.start(queue: queue)
    }
    
    /// Retorna um Stream assíncrono seguro.
    /// Não importa quantas vezes seja chamado, ele não cria vazamentos.
    func statusStream() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            // 1. Criamos uma assinatura no nosso Subject
            let cancellable = statusSubject
                .removeDuplicates() // Evita enviar o mesmo valor repetido
                .sink { status in
                    continuation.yield(status)
                }
            
            // 2. Limpeza automática.
            // Quando quem chamou o stream desistir ou a Task for cancelada,
            // este bloco limpa a assinatura do Combine.
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}
