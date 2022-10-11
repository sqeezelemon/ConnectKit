// ConnectKit
// ↳ C2Client.swift
//
// Created by:
// Alexander Nikitin - @sqeezelemon

import Foundation
import Network

/// Client for Connect API V2.
public final class C2Client {
    
    //MARK: Properties
    
    /// Delegate used by the client.
    public weak var delegate: C2ClientDelegate?
    
    /// States from the manifest, sorted by their numeric ID.
    public private(set) var states: [C2State] = []
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
    /// Queue used by the connection
    private let queue: DispatchQueue
    
    /// Buffer used for decoding.
    private var buffer: Data = Data()
    /// Lookup table for where each state is in the `states` array.
    private var stateIndexByName: [String : Int] = [:]
    
    
    //MARK: Initialisers
    
    /// Creates a `C2Client` instance.
    ///
    /// - Parameter queue: `DispatchQueue` on which all delegate events would be delivered.
    public init(queue: DispatchQueue = .init(label: "ConnectV2",
                                             qos: .userInteractive)) {
        self.queue = queue
    }
    
    
    //MARK: Utilities
    
    /// Finds the state by its numeric ID.
    ///
    /// - Parameter id: Numeric ID of the state.
    /// - Complexity: Binary search - `O(n•logn)`
    public func findState(by id: Int32) -> C2State? {
        var l = 0
        var r = states.count - 1
        while (l < r) {
            let m = (l+r)/2
            
            if (states[m].id > id) {
                r = m - 1
            } else if (states[m].id < id) {
                l = m + 1
            } else {
                return states[m]
            }
        }
        return nil
    }
    
    /// Finds the state by its name.
    ///
    /// - Parameter name: Name of the state.
    public func findState(by name: String) -> C2State? {
        guard let index = stateIndexByName[name],
              index <= states.count
        else {
            return nil
        }
        return states[index]
    }
    
    /// Checks whether the state exists and was sent the right type while in debug mode.
    private func checkState(_ id: Int32, type: C2StateType) {
#if DEBUG
        guard let state = findState(by: id) else {
            print("Request sent to nonexistent ID \(id)")
            return
        }
        if state.type != type {
            print("Request with type \(type) sent to state \(id) of type \(state.type)")
        }
#endif
    }
    
    //MARK: Networking
    
    /// Connects to Infinite Flight.
    ///
    /// - Parameter ip: IPv4 address of the Infinite Flight session.
    public func connect(to ip: NWEndpoint.Host) {
        if (connection != nil) { disconnect() }
        connection = NWConnection(host: ip, port: 10112, using: .tcp)
        connection?.stateUpdateHandler = stateDidChange(to:)
        self.listen()
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
        case .ready:
            delegate?.c2clientDidConnect(self)
            self.getManifest()
        case .failed(let error):
            delegate?.c2clientDidReceive(self, error: error)
        default:
            break
        }
    }
    
    /// Listens for data on the connection.
    private func listen() {
        connection?.receiveMessage { (data, contentContext, isComplete, error) in
            if let data = data, !data.isEmpty {
                if (!self.buffer.isEmpty) {
                    self.buffer.append(contentsOf: data)
                } else {
                    self.buffer = data
                }
                self.decode()
            }
            
            if isComplete {
                self.disconnect()
            } else if let error = error {
                self.delegate?.c2clientDidReceive(self, error: error)
            } else {
                self.listen()
            }
        }
    }
    
    /// Decodes incoming data.
    private func decode() {
        // Check that header is available.
        guard (buffer.count > 8) else { return }
        
        let id   = Int32(littleEndian: buffer.withUnsafeBytes {$0.load(as: Int32.self)})
        let size = Int32(littleEndian: buffer.advanced(by: 4).withUnsafeBytes { $0.load(as: Int32.self)} )
        
        // Check that all data arrived.
        guard (buffer.count >= 8 + size) else { return }
        
        defer {
            buffer = buffer.advanced(by: 8 + Int(size))
            decode()
        }
        
        if (id == -1) {
            decodeManifest()
            return
        }
        
        guard let state = findState(by: id) else { return }
        
        switch state.type {
        case .bool:
            guard size == 1 else { break }
            let data = buffer.advanced(by: 8).withUnsafeBytes { $0.load(as: Bool.self)}
            self.delegate?.c2clientDidReceive(self, data: data, for: id)
            
        case .int:
            guard size == 4 else { break }
            let data = Int32(littleEndian: buffer.advanced(by: 8).withUnsafeBytes { $0.load(as: Int32.self)})
            self.delegate?.c2clientDidReceive(self, data: data, for: id)
            
        case .float:
            guard size == 4 else { break }
            let data = Float(UInt32(littleEndian: buffer.advanced(by: 8).withUnsafeBytes { $0.load(as: UInt32.self)}))
            self.delegate?.c2clientDidReceive(self, data: data, for: id)
            
        case .double:
            guard size == 8 else { break }
            let data = Double(UInt64(littleEndian: buffer.advanced(by: 8).withUnsafeBytes { $0.load(as: UInt64.self)}))
            self.delegate?.c2clientDidReceive(self, data: data, for: id)
            
        case .string:
            let strLen = Int32(littleEndian: buffer.advanced(by: 8).withUnsafeBytes { $0.load(as: Int32.self)})
            guard let data = String(data: buffer[12..<12+Int(strLen)], encoding: .utf8) else { break }
            self.delegate?.c2clientDidReceive(self, data: data, for: id)
            
        case .long:
            guard size == 8 else { break }
            let data = Int64(littleEndian: buffer.advanced(by: 8).withUnsafeBytes { $0.load(as: Int64.self)})
            self.delegate?.c2clientDidReceive(self, data: data, for: id)
            
        default:
            break
        }
    }
    
    private func decodeManifest() {
        let strLen = Int32(littleEndian: buffer.advanced(by: 8).withUnsafeBytes { $0.load(as: Int32.self)})
        guard let str = String(data: buffer[12..<12+Int(strLen)], encoding: .utf8) else { return }
        
        states.removeAll()
        stateIndexByName.removeAll()
        
        for line in str.split(separator: "\n") {
            let comps = line.split(separator: ",")
            guard comps.count >= 3 else { continue }
            
            if let id = Int32(comps[0]),
               let type = Int32(comps[1]) {
                let state = C2State(
                    id: id,
                    name: String(comps[2]),
                    type: .init(rawValue: type) ?? .unknown)
                states.append(state)
            }
        }
        
        states.sort { $0.id < $1.id }
        
        for i in 0..<states.count {
            let state = states[i]
            stateIndexByName[state.name] = i
        }
        
        self.delegate?.c2clientDidReceive(self, manifest: states)
    }
    
    private func send(_ data: Data) {
        connection?.send(content: data, completion: .contentProcessed({ (error) in
            if let error = error {
                self.delegate?.c2clientDidReceive(self, error: error)
            }
        }))
    }
    
    //MARK: User interaction
    
    /// Sets `id` to the provided `Bool`.
    /// - Parameters:
    ///   - id: Numeric ID of the state.
    ///   - bool: `Bool` to set the state to.
    public func set(_ id: Int32, bool: Bool) {
        checkState(id, type: .bool)
        
        let buffSize = (
            MemoryLayout<Int32>.size  // ID
            + MemoryLayout<Bool>.size // Write
            + MemoryLayout<Bool>.size // Data
        )
        let buff = UnsafeMutableRawPointer.allocate(byteCount: buffSize, alignment: 1)
        
        var id = id.littleEndian
        var writeFlag = true
        var value = bool
        
        (buff + 0).copyMemory(from: &id,        byteCount: 4)
        (buff + 4).copyMemory(from: &writeFlag, byteCount: 1)
        (buff + 5).copyMemory(from: &value,     byteCount: 1)
        
        let data = Data(bytes: buff, count: buffSize)
        send(data)
    }
    
    /// Sets `id` to the provided `Int32`.
    /// - Parameters:
    ///   - id: Numeric ID of the state.
    ///   - int: `Int32` to set the state to.
    public func set(_ id: Int32, int: Int32) {
        checkState(id, type: .int)
        
        let buffSize = (
            MemoryLayout<Int32>.size   // ID
            + MemoryLayout<Bool>.size  // Write
            + MemoryLayout<Int32>.size // Data
        )
        let buff = UnsafeMutableRawPointer.allocate(byteCount: buffSize, alignment: 1)
        
        var id = id.littleEndian
        var writeFlag = true
        var value = int.littleEndian
        
        (buff + 0).copyMemory(from: &id,        byteCount: 4)
        (buff + 4).copyMemory(from: &writeFlag, byteCount: 1)
        (buff + 5).copyMemory(from: &value,     byteCount: 4)
        
        let data = Data(bytes: buff, count: buffSize)
        send(data)
    }
    
    /// Sets `id` to the provided `Float`.
    /// - Parameters:
    ///   - id: Numeric ID of the state.
    ///   - float: `Float` to set the state to.
    public func set(_ id: Int32, float: Float) {
        checkState(id, type: .float)
        
        let buffSize = (
            MemoryLayout<Int32>.size   // ID
            + MemoryLayout<Bool>.size  // Write
            + MemoryLayout<Float>.size // Data
        )
        let buff = UnsafeMutableRawPointer.allocate(byteCount: buffSize, alignment: 1)
        
        var id = id.littleEndian
        var writeFlag = true
        var value = float.bitPattern.littleEndian
        
        (buff + 0).copyMemory(from: &id,        byteCount: 4)
        (buff + 4).copyMemory(from: &writeFlag, byteCount: 1)
        (buff + 5).copyMemory(from: &value,     byteCount: 4)
        
        let data = Data(bytes: buff, count: buffSize)
        send(data)
    }
    
    /// Sets `id` to the provided `String`.
    /// - Parameters:
    ///   - id: Numeric ID of the state.
    ///   - string: `String` to set the state to.
    public func set(_ id: Int32, string: String) {
        checkState(id, type: .string)
        
        guard var strData = string.data(using: .utf8) else { return }
        
        let buffSize = (
            MemoryLayout<Int32>.size   // ID
            + MemoryLayout<Bool>.size  // Write
            + MemoryLayout<Int32>.size // String size
            + strData.count            // String
        )
        let buff = UnsafeMutableRawPointer.allocate(byteCount: buffSize, alignment: 1)
        
        var id = id.littleEndian
        var writeFlag = true
        var strSize = Int32(strData.count).littleEndian
        
        (buff + 0).copyMemory(from: &id,        byteCount: 4)
        (buff + 4).copyMemory(from: &writeFlag, byteCount: 1)
        (buff + 5).copyMemory(from: &strSize,   byteCount: 4)
        (buff + 9).copyMemory(from: &strData,   byteCount: strData.count)
        
        let data = Data(bytes: buff, count: buffSize)
        send(data)
    }
    
    /// Sets `id` to the provided `Double`.
    /// - Parameters:
    ///   - id: Numeric ID of the state.
    ///   - double: `Double` to set the state to.
    public func set(_ id: Int32, double: Double) {
        checkState(id, type: .double)
        
        let buffSize = (
            MemoryLayout<Int32>.size   // ID
            + MemoryLayout<Bool>.size  // Write
            + MemoryLayout<Double>.size // Data
        )
        let buff = UnsafeMutableRawPointer.allocate(byteCount: buffSize, alignment: 1)
        
        var id = id.littleEndian
        var writeFlag = true
        var value = double.bitPattern.littleEndian
        
        (buff + 0).copyMemory(from: &id,        byteCount: 4)
        (buff + 4).copyMemory(from: &writeFlag, byteCount: 1)
        (buff + 5).copyMemory(from: &value,     byteCount: 8)
        
        let data = Data(bytes: buff, count: buffSize)
        send(data)
    }
    
    /// Sets `id` to the provided `Int64`.
    /// - Parameters:
    ///   - id: Numeric ID of the state.
    ///   - long: `Int64` to set the state to.
    public func set(_ id: Int32, long: Int64) {
        checkState(id, type: .long)
        
        let buffSize = (
            MemoryLayout<Int32>.size   // ID
            + MemoryLayout<Bool>.size  // Write
            + MemoryLayout<Int64>.size // Data
        )
        let buff = UnsafeMutableRawPointer.allocate(byteCount: buffSize, alignment: 1)
        
        var id = id.littleEndian
        var writeFlag = true
        var value = long.littleEndian
        
        (buff + 0).copyMemory(from: &id,        byteCount: 4)
        (buff + 4).copyMemory(from: &writeFlag, byteCount: 1)
        (buff + 5).copyMemory(from: &value,     byteCount: 8)
        
        let data = Data(bytes: buff, count: buffSize)
        send(data)
    }
    
    /// Retrieves the state for the delegate to process.
    ///
    /// - Parameter id: Numeric ID of the state.
    public func get(_ id: Int32) {
        let buffSize = (
            MemoryLayout<Int32>.size   // ID
            + MemoryLayout<Bool>.size  // Read
        )
        let buff = UnsafeMutableRawPointer.allocate(byteCount: buffSize, alignment: 1)
        
        var id = id.littleEndian
        var writeFlag = false
        
        (buff + 0).copyMemory(from: &id,        byteCount: 4)
        (buff + 4).copyMemory(from: &writeFlag, byteCount: 1)
        
        let data = Data(bytes: buff, count: buffSize)
        send(data)
    }
    
    /// Sends a command.
    ///
    /// - Parameter id: Numeric ID of the command.
    public func command(_ id: Int32) {
        get(id)
    }
    
    /// Retrieves the manifest for the delegate to process.
    ///
    /// - Note: Manifest will also be available with the `.states` property, as well as `getState(by:)` methods.
    public func getManifest() {
        get(-1)
    }
}
