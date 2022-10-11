// ConnectKit
// ↳ FFPosition.swift
//
// Created by:
// Alexander Nikitin - @sqeezelemon

import Foundation

/// Position of the aircraft.
///
/// - Attention: Unlike almost any endpoint, this one uses meters instead of feet.
public struct FFPosition {
    /// Longitude of the aircraft.
    public var longitude: Float
    /// Latitude of the aircraft.
    public var latitude: Float
    /// MSL altitude in **meters**.
    public var altitude: Float
    /// Track along ground from true north in degrees. Always positive.
    public var track: Float
    /// Ground speed in **meters/sec**.
    public var groundSpeed: Float
}
