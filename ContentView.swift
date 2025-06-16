import SwiftUI
import Network

struct ContentView: View {
    @State private var pingResult: String = "Press Test Ping"
    @State private var isGameOptimizerOn = false
    
    let vpnServers = [
        ("Europe Server 1", "10.0.0.1"),
        ("Europe Server 2", "10.0.0.2")
    ]
    
    @State private var selectedServerIndex = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Faisal Game")
                    .font(.largeTitle)
                    .bold()
                
                Picker("Select VPN Server", selection: $selectedServerIndex) {
                    ForEach(0..<vpnServers.count, id: \.self) { index in
                        Text(vpnServers[index].0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Button("Test Ping") {
                    testPing(to: vpnServers[selectedServerIndex].1)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Text("Ping Result: \(pingResult)")
                    .font(.headline)
                
                Toggle("Game Optimizer", isOn: $isGameOptimizerOn)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Faisal Game")
        }
    }
    
    func testPing(to host: String) {
        pingResult = "Pinging..."
        
        let monitor = NWPathMonitor(requiredInterfaceType: .other)
        let queue = DispatchQueue(label: "PingMonitor")
        
        let startTime = Date()
        let host = NWEndpoint.Host(host)
        let port = NWEndpoint.Port(rawValue: 80) ?? 80
        
        let connection = NWConnection(host: host, port: port, using: .tcp)
        
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                let latency = Date().timeIntervalSince(startTime) * 1000
                DispatchQueue.main.async {
                    self.pingResult = String(format: "%.0f ms", latency)
                }
                connection.cancel()
            case .failed(_):
                DispatchQueue.main.async {
                    self.pingResult = "Failed"
                }
                connection.cancel()
            default:
                break
            }
        }
        
        connection.start(queue: queue)
    }
}
