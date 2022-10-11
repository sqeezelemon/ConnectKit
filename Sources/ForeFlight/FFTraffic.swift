// ConnectKit
// ↳ FFTraffic.swift
//
// Created by:
// Alexander Nikitin - @sqeezelemon

import Foundation

/// A traffic object.
public struct FFTraffic {
    /// Unique identifier of the traffic object.
    public var id: Int
    /// Latitude of the traffic object.
    public var latitude: Float
    /// Longitude of the traffic object.
    public var longitude: Float
    /// Altitude above ground in **feet**.
    public var altitude: Float
    /// Vertical speed in **feet/min**.
    public var verticalSpeed: Float
    /// Whether the traffic is airborne.
    public var isAirborne: Bool
    /// Track in true degrees.
    public var track: Float
    /// Speed in **knots**.
    public var speed: Float
    /// Callsign of the traffic object, not unique.
    public var callsign: String
}
