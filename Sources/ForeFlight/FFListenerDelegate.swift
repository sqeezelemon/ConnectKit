// ConnectKit
// ↳ FFListenerDelegate.swift
//
// Created by:
// Alexander Nikitin - @sqeezelemon

import Foundation

/// Defines a delegate for a `FFListener`.
public protocol FFListenerDelegate: AnyObject {
    
    /// Tells the delegate that the client encountered an error.
    ///
    /// - Parameters:
    ///   - client: The active `FFListener`.
    ///   - error: The `Error` that was received.
    func fflistenerDidReceiveError(_ client: FFListener,
                                   error: Error)
    
    /// Tells the delegate that the client received the position of the aircraft.
    ///
    /// - Parameters:
    ///   - client: The active `FFListener`.
    ///   - position: Position of the aircraft.
    func fflistenerDidReceive(_ client: FFListener,
                              position: FFPosition)
    
    /// Tells the delegate that the client received info about a traffic object.
    ///
    /// - Parameters:
    ///   - client: The active `FFListener`.
    ///   - traffic: A single traffic `FFTraffic` object.
    func fflistenerDidReceive(_ client: FFListener,
                              traffic: FFTraffic)
    
    /// Tells the delegate that the client received the attitude of the aircraft.
    ///
    /// - Parameters:
    ///   - client: The active `FFListener`.
    ///   - attitude: Attitude of the aircraft.
    func fflistenerDidReceive(_ client: FFListener,
                              attitude: FFAttitude)
}
