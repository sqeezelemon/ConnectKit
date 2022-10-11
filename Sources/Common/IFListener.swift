// ConnectKit
// ↳ IFListener.swift
//
// Created by:
// Alexander Nikitin - @sqeezelemon

import Foundation
import Network

/// Listens for active Infinite Flight sessions.
public final class IFListener {
    /// Listener used by the connection.
    private var listener: NWListener?
    /// Queue used by the connection.
    private var queue: DispatchQueue
    
    /// A handler that receives Infinite Flight sessions found by the listener.
    public var sessionHandler: ((IFSession) -> Void)?
    /// Whether the listener should stop after discovering one.
    public var stopAfterDiscovery: Bool = true
    /// Whether the listener is active.
    public var isActive: Bool { return listener != nil }
    
    /// Creates a `IFListener` instance.
    ///
    /// - Parameter queue: `DispatchQueue` on which the session info will be delivered.
    public init(queue: DispatchQueue = .init(label: "IFListener",
                                             qos: .userInteractive)) {
        self.queue = queue
    }
    
    /// Starts listening for active Infinite Flight sessions.
    public func start() {
        stop()
        listener = try? NWListener(using: .udp, on: 15000)
        listener?.newConnectionHandler = connectionHandler(_:)
        listener?.stateUpdateHandler = { newState in
            switch newState {
            case .failed:
                self.stop()
            default:
                break
            }
        }
        listener?.start(queue: queue)
    }
    
    /// Stops listening for active Infinite Flight sessions.
    public func stop() {
        if (listener != nil) {
            listener?.cancel()
            listener = nil
        }
    }
    
    /// Handles the connections discovered by the listener.
    private func connectionHandler(_ connection: NWConnection) {
        stop()
        read(on: connection)
        connection.start(queue: queue)
    }
    
    /// Reads data from the connection.
    private func read(on connection: NWConnection) {
        connection.receiveMessage { (data, contentContext, isComplete, error) in
            if let data = data,
               let session = try? JSONDecoder().decode(IFSession.self, from: data) {
                self.sessionHandler?(session)
            }
            
            if isComplete {
                connection.cancel()
                if !self.stopAfterDiscovery {
                    self.start()
                }
            } else if error != nil {
                connection.cancel()
                self.start()
            } else {
                self.read(on: connection)
            }
        }
    }
}
