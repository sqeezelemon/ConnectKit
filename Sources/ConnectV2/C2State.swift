// ConnectKit
// ↳ C2State.swift
//
// Created by:
// Alexander Nikitin - @sqeezelemon

import Foundation

/// A state obtained from Connect V2 API.
public struct C2State {
    public init(id: Int32, name: String, type: C2StateType) {
        self.id = id
        self.name = name
        self.type = type
    }
    
    /// Numeric ID of the state. This can vary between aircraft.
    public let id: Int32
    /// Name of the state. This doesn't change between aircraft.
    public let name: String
    /// Type of the state.
    public let type: C2StateType
}
