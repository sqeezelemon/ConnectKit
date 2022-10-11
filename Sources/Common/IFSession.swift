// ConnectKit
// ↳ IFSession.swift
//
// Created by:
// Alexander Nikitin - @sqeezelemon

import Foundation

/// Active Infinite Flight session.
public struct IFSession {
    public init(ipv4: String, addresses: [String], state: String, version: String, deviceId: String, deviceName: String, aircraft: String, livery: String) {
        self.ipv4 = ipv4
        self.addresses = addresses
        self.state = state
        self.version = version
        self.deviceId = deviceId
        self.deviceName = deviceName
        self.aircraft = aircraft
        self.livery = livery
    }
    
    /// IPv4 address to which the connection should be established.
    public var ipv4: String
    /// All IP addresses of the session.
    public var addresses: [String]
    /// The state of the session, i.e. `"Playing"`.
    public var state: String
    /// IF version the session is running on.
    ///
    /// The version number breaks down as follows:
    /// ```
    /// 22.5 - Major version.
    /// 1    - Minor version.
    /// 1927 - Build number.
    ///  ```
    public var version: String
    /// ID of the device model the session is running on.
    public var deviceId: String
    /// User defined name of the device the session is running on.
    public var deviceName: String
    /// Name of the aircraft used in the session.
    public var aircraft: String
    /// Name of the aircraft used in the session.
    public var livery: String
}

extension IFSession: Decodable {
    private enum CodingKeys: String, CodingKey {
        case addresses = "Addresses"
        case state = "State"
        case version = "Version"
        case deviceId = "DeviceID"
        case deviceName = "DeviceName"
        case aircraft = "Aircraft"
        case livery = "Livery"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        state = (try? container.decode(String.self, forKey: .state)) ?? ""
        version = (try? container.decode(String.self, forKey: .version)) ?? ""
        deviceId = (try? container.decode(String.self, forKey: .deviceId)) ?? ""
        deviceName = (try? container.decode(String.self, forKey: .deviceName)) ?? ""
        aircraft = (try? container.decode(String.self, forKey: .aircraft)) ?? ""
        livery = (try? container.decode(String.self, forKey: .livery)) ?? ""
        addresses = try container.decode([String].self, forKey: .addresses)
        
        for ip in addresses {
            if ip.range(of: #"^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$"#, options: .regularExpression) != nil {
                ipv4 = ip
                return
            }
        }
        throw DecodingError.valueNotFound(
            String.self,
            .init(codingPath: [CodingKeys.addresses],
                  debugDescription: "IPv4 address not found in addresses array")
        )
    }
}
