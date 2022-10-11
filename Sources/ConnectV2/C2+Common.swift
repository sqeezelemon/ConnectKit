// ConnectKit
// ↳ C2+Common.swift
//
// Created by:
// Alexander Nikitin - @sqeezelemon

import Foundation
import Network
@_exported import _ConnectKitCommon

public extension C2Client {
    /// Connects to Infinite Flight.
    ///
    /// - Parameter session: Session obtained from `IFListener`.
    func connect(to session: IFSession) {
        return connect(to: NWEndpoint.Host(session.ipv4))
    }
}
