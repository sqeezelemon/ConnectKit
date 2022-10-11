// ConnectKit
// ↳ FFListener.swift
//
// Created by:
// Alexander Nikitin - @sqeezelemon

// Reference: https://www.foreflight.com/support/network-gps/

import Foundation
import Network

/// Listens to ForeFlight broadcasts.
public final class FFListener {
    
    //MARK: Properties
    
    /// Delegate used by the client.
    public weak var delegate: FFListenerDelegate?
    /// Listener used for discovering UDP broadcasts
    private var listener: NWListener?
    /// Current connection used by the client.
    private var currConnection: NWConnection?
    /// Queue used for the connections
    private var queue: DispatchQueue
    /// Listener parameters
    private let params: NWParameters
    
    //MARK: Public methods
    
    /// Creates a `FFListener` instance.
    ///
    /// - Parameter queue: `DispatchQueue` on which all delegate events would be delivered.
    public init(queue: DispatchQueue = .init(label: "FFListener",
                                             qos: .userInteractive)) {
        self.queue = queue
        params = NWParameters.udp
        params.allowLocalEndpointReuse = true
    }
    
    /// Starts the listener.
    public func start() {
        stop()
        
        listener = try? NWListener(using: params, on: 49002)
        listener?.stateUpdateHandler = listenerStateDidChange(to:)
        listener?.newConnectionHandler = newConnectionHandler(_:)
        listener?.start(queue: queue)
    }
    
    /// Stops the listener.
    public func stop() {
        if listener != nil {
            listener?.cancel()
            listener?.cancel()
        }
    }
    
    //MARK: Backend
    
    private func listenerStateDidChange(to state: NWListener.State) {
        switch state {
        case .failed(let error):
            self.delegate?.fflistenerDidReceiveError(self, error: error)
        default:
            break
        }
    }
    
    private func connectionStateDidChange(to state: NWConnection.State) {
        switch state {
        case .failed(let error):
            self.delegate?.fflistenerDidReceiveError(self, error: error)
        default:
            break
        }
    }
    
    private func newConnectionHandler(_ connection: NWConnection) {
        connection.stateUpdateHandler = connectionStateDidChange(to:)
        read(on: connection)
        self.stop()
        connection.start(queue: queue)
    }
    
    private func read(on connection: NWConnection) {
        connection.receiveMessage { (data, contentContext, isComplete, error) in
            if let data = data, !data.isEmpty {
                self.decode(data)
            }
            
            if isComplete {
                connection.cancel()
                self.start()
            } else if let error = error {
                self.delegate?.fflistenerDidReceiveError(self, error: error)
            } else {
                self.read(on: connection)
            }
        }
    }
    
    //MARK: Decoding
    
    private func decode(_ data: Data) {
        guard let str = String(data: data, encoding: .utf8) else { return }
        let comps = str.split(separator: ",")
        if str.hasPrefix("XGPS") && comps.count >= 6 {
            if let lon = Float(comps[1]),
               let lat = Float(comps[2]),
               let alt = Float(comps[3]),
               let trk = Float(comps[4]),
               let gs = Float(comps[5]) {
                let position = FFPosition(longitude: lon,
                                          latitude: lat,
                                          altitude: alt,
                                          track: trk,
                                          groundSpeed: gs)
                self.delegate?.fflistenerDidReceive(self, position: position)
            }
        } else if str.hasPrefix("XATT") && comps.count >= 4 {
            if let heading = Float(comps[1]),
               let pitch = Float(comps[2]),
               let roll = Float(comps[3]) {
                let attitude = FFAttitude(heading: heading,
                                          pitch: pitch,
                                          roll: roll)
                self.delegate?.fflistenerDidReceive(self, attitude: attitude)
            }
        } else if str.hasPrefix("XTRAFFIC") && comps.count >= 10 {
            
            if let id = Int(comps[1]),
               let lat = Float(comps[2]),
               let lon = Float(comps[3]),
               let alt = Float(comps[4]),
               let vs = Float(comps[5]),
               let abFlag = Int(comps[6]),
               let trk = Float(comps[7]),
               let spd = Float(comps[8]) {
                let traffic = FFTraffic(id: id,
                                        latitude: lat,
                                        longitude: lon,
                                        altitude: alt,
                                        verticalSpeed: vs,
                                        isAirborne: abFlag == 1,
                                        track: trk,
                                        speed: spd,
                                        callsign: String(comps[9]))
                self.delegate?.fflistenerDidReceive(self, traffic: traffic)
            }
        }
    }
}
