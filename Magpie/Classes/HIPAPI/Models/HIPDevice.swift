//
//  HIPDevice.swift
//  Pods
//
//  Created by Karasuluoglu on 2.11.2020.
//

import Foundation

open class HIPDevice {
    public let os: OS
    public let osVersion: String
    public let model: String

    public init() {
        let rawDevice = UIDevice.current

        #if os(macOS)
        os = .macOS
        #elseif os(watchOS)
        os = .watchOS
        #elseif os(tvOS)
        os = .tvOS
        #else
        os = .iOS
        #endif

        osVersion = rawDevice.systemVersion

        #if targetEnvironment(simulator)
        model = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "simulator"
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        model = machineMirror.children.reduce("") { aModel, elem in
            guard let value = elem.value as? Int8, value != 0 else {
                return aModel
            }
            return aModel + String(UnicodeScalar(UInt8(value)))
        }
        #endif
    }
}

extension HIPDevice {
    public enum OS: String, Printable {
        case iOS = "iOS"
        case macOS = "macOS"
        case watchOS = "watchOS"
        case tvOS = "tvOS"
    }
}

extension HIPDevice: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(model) \(os.debugDescription) \(osVersion)"
    }
}
