// ConnectKit
// ↳ FFAttitude.swift
//
// Created by:
// Alexander Nikitin - @sqeezelemon

import Foundation

/// Attitude of the aircraft.
public struct FFAttitude {
    /// Heading in true degrees.
    public var heading: Float
    /// Aircraft pitch in degrees (up is positive).
    public var pitch: Float
    /// Aircraft roll in degrees (right is positive).
    public var roll: Float
}
