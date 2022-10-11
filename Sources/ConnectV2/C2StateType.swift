// ConnectKit
// ↳ C2StateType.swift
//
// Created by:
// Alexander Nikitin - @sqeezelemon

import Foundation

public enum C2StateType: Int32 {
    case command = -1
    case bool = 0
    case int = 1
    case float = 2
    case double = 3
    case string = 4
    case long = 5
    case unknown = 404
}

extension C2StateType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .command:
            return "Command"
        case .bool:
            return "Bool"
        case .int:
            return "Integer (Int32)"
        case .float:
            return "Float"
        case .double:
            return "Double"
        case .string:
            return "String"
        case .long:
            return "Long (Int64)"
        case .unknown:
            return "Unknown type"
        }
    }
}
