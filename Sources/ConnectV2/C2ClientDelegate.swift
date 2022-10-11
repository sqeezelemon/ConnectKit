// ConnectKit
// ↳ C2ClientDelegate.swift
//
// Created by:
// Alexander Nikitin - @sqeezelemon

import Foundation

/// Defines a delegate for a `C2Client`.
public protocol C2ClientDelegate: AnyObject {
    
    /// Tells the delegate that the client did successfully connect.
    /// Note that the client automatically fetches the manifest after this.
    ///
    /// - Parameter client: The active `C2Client`.
    func c2clientDidConnect(_ client: C2Client)
    
    /// Tells the delegate that the client received an `Error`.
    ///
    /// - Parameters:
    ///   - client: The active `C2Client`.
    ///   - error: The `Error` that was received.
    func c2clientDidReceive(_ client: C2Client,
                            error: Error)
    
    /// Tells the delegate that the client received a response for a `Bool` property.
    ///
    /// - Parameters:
    ///   - client: The active `C2Client`.
    ///   - data: The `Bool` that was received.
    ///   - id: Numeric ID of the state for which the `Bool` was received.
    func c2clientDidReceive(_ client: C2Client,
                            data: Bool,
                            for id: Int32)
    
    /// Tells the delegate that the client received a response for a `Int32` property.
    ///
    /// - Parameters:
    ///   - client: The active `C2Client`.
    ///   - data: The `Int32` that was received.
    ///   - id: Numeric ID of the state for which the `Int32` was received.
    func c2clientDidReceive(_ client: C2Client,
                            data: Int32,
                            for id: Int32)
    
    /// Tells the delegate that the client received a response for a `Float` property.
    ///
    /// - Parameters:
    ///   - client: The active `C2Client`.
    ///   - data: The `Float` that was received.
    ///   - id: Numeric ID of the state for which the `Float` was received.
    func c2clientDidReceive(_ client: C2Client,
                            data: Float,
                            for id: Int32)
    
    /// Tells the delegate that the client received a response for a `Double` property.
    ///
    /// - Parameters:
    ///   - client: The active `C2Client`.
    ///   - data: The `Double` that was received.
    ///   - id: Numeric ID of the state for which the `Double` was received.
    func c2clientDidReceive(_ client: C2Client,
                            data: Double,
                            for id: Int32)
    
    /// Tells the delegate that the client received a response for a `String` property.
    ///
    /// - Parameters:
    ///   - client: The active `C2Client`.
    ///   - data: The `String` that was received.
    ///   - id: Numeric ID of the state for which the `String` was received.
    func c2clientDidReceive(_ client: C2Client,
                            data: String,
                            for id: Int32)
    
    /// Tells the delegate that the client received a response for a `Int64` property.
    ///
    /// - Parameters:
    ///   - client: The active `C2Client`.
    ///   - data: The `Int64` that was received.
    ///   - id: Numeric ID of the state for which the `Int64` was received.
    func c2clientDidReceive(_ client: C2Client,
                            data: Int64,
                            for id: Int32)
    
    /// Tells the delegate that the client received the manifest.
    ///
    /// - Parameters:
    ///   - client: The active `C2Client`.
    ///   - manifest: An array of `C2State` objects, sorted by ID.
    func c2clientDidReceive(_ client: C2Client,
                            manifest: [C2State])
}

public extension C2ClientDelegate {
    
    func c2clientDidConnect(_ client: C2Client) { }
    
    func c2clientDidReceive(_ client: C2Client,
                            error: Error) {
        print("C2Client error: \(error.localizedDescription)")
    }
    
    func c2clientDidReceive(_ client: C2Client,
                            data: Int32,
                            for id: Int32) {
        c2clientDidReceive(client, data: Int64(data), for: id)
    }
    
    func c2clientDidReceive(_ client: C2Client,
                            data: Float,
                            for id: Int32) {
        c2clientDidReceive(client, data: Double(data), for: id)
    }
    
    func c2clientDidReceive(_ client: C2Client,
                            manifest: [C2State]) { }
}
