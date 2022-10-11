// ConnectKit
// ↳ OTClient.swift
//
// Created by:
// Alexander Nikitin - @sqeezelemon

import Foundation
import Network

/// Client for OpenTrack API.
public final class OTClient {
    
    //MARK: Properties
    /// A handler that receives errors encountered by the client.
    public var errorHandler: ((Error) -> Void)?
    
    /// Host to which the connection is established or `nil`.
    public var host: NWEndpoint.Host? {
        switch connection?.endpoint {
        case .hostPort(let host, _):
            return host
        default:
            return nil
        }
    }
    
    /// Connection used by the client.
    private var connection: NWConnection?
    /// Queue used by the client.
    private var queue: DispatchQueue
    
    /// Creates a `OTClient` instance.
    /// - Parameter queue: `DispatchQueue` used by the connection.
    public init(queue: DispatchQueue = .init(label: "OTClient",
                                             qos: .userInteractive)) {
        self.queue = queue
    }
    
    //MARK: Connection
    
    /// Connects to Infinite Flight.
    ///
    /// - Parameter ip: IPv4 address of the Infinite Flight session.
    public func connect(to ip: NWEndpoint.Host) {
        if (connection != nil) { disconnect() }
        connection = NWConnection(host: ip, port: 4242, using: .udp)
        connection?.stateUpdateHandler = stateDidChange(to:)
        connection?.start(queue: queue)
    }
    
    /// Disconnects from Infinite Flight.
    public func disconnect() {
        if connection != nil {
            connection?.cancel()
            connection = nil
        }
    }
    
    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .failed(let error):
            self.errorHandler?(error)
        default:
            break
        }
    }
    
    //MARK: User Interaction
    
    /// Positions the cockpit camera to the provided position.
    /// - Parameters:
    ///  - x: X-axis offset in meters.
    ///  - y: Y-axis offset in meters.
    ///  - z: Z-axis offset in meters.
    ///  - roll: Roll offset in radians.
    ///  - pitch: Pitch offset in radians.
    ///  - yaw: Yaw offset in radians.
    public func send(x: Double, y: Double, z: Double,
                     roll:  Double, pitch: Double, yaw:   Double) {
        var values: [UInt64] = [x, y, z, yaw, pitch, roll].map { $0.bitPattern.littleEndian }
        let data = NSData(bytes: &values, length: MemoryLayout<Double>.size*6)
        connection?.send(content: Data(data), completion: .contentProcessed({ (error) in
            if let error = error {
                self.errorHandler?(error)
            }
        }))
    }
}
