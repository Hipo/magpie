//
//  HIPDevice.swift
//  Pods
//
//  Created by Karasuluoglu on 2.11.2020.
//

import Foundation

#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

open class HIPDevice {
    public let os: OS
    public let osVersion: String
    public let family: Family
    public let model: String
    public let locale: Locale
    public let vendorIdentifier: String
    public let hasNotch: Bool

    public init() {
        let processInfo = ProcessInfo.processInfo

        os = .current
        family = .current

        let operatingSystem = processInfo.operatingSystemVersion
        osVersion = "\(operatingSystem.majorVersion).\(operatingSystem.minorVersion).\(operatingSystem.patchVersion)"

        #if targetEnvironment(simulator)
        model = processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "simulator"
        #else
        /// <ref> https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlSysctl.swift
        let keys: [Int32]

        #if os(macOS)
        keys = [CTL_HW, HW_MODEL]
        #else
        keys = [CTL_HW, HW_MACHINE]
        #endif

        let modelData = keys.withUnsafeBufferPointer { keysPointer -> [Int8]? in
            var requiredSize = 0
            let preFlightResult = Darwin.sysctl(UnsafeMutablePointer<Int32>(mutating: keysPointer.baseAddress), UInt32(keys.count), nil, &requiredSize, nil, 0)

            if preFlightResult != 0 {
                return nil
            }

            let data = Array<Int8>(repeating: 0, count: requiredSize)
            let result = try? data.withUnsafeBufferPointer() { dataBuffer throws -> Int32 in
                return Darwin.sysctl(UnsafeMutablePointer<Int32>(mutating: keysPointer.baseAddress), UInt32(keys.count), UnsafeMutableRawPointer(mutating: dataBuffer.baseAddress), &requiredSize, nil, 0)
            }

            if result != 0 {
                return nil
            }
            return data
        }
        model = modelData?.withUnsafeBufferPointer { dataPointer -> String? in
            dataPointer.baseAddress.flatMap { String(validatingUTF8: $0) }
        } ?? "Unknown"
        #endif

        locale = Locale.preferred

        #if canImport(UIKit)
        if let systemIdentiifer = UIDevice.current.identifierForVendor?.uuidString {
            vendorIdentifier = systemIdentiifer
        } else {
            /// <note>
            /// Normally, it shouldn't be enter this block but it is just a precaution to handle
            /// a null value for a minor possibility.
            let userDefaults = UserDefaults.standard
            let application = HIPApplication()
            let cacheIdentifierKey = "\(application.packageName).vendorIdentifier"

            if let cacheIdentifier =
                userDefaults.string(
                    forKey: cacheIdentifierKey
                ) {
                vendorIdentifier = cacheIdentifier
            } else {
                vendorIdentifier = UUID().uuidString

                userDefaults.setValue(
                    vendorIdentifier,
                    forKey: cacheIdentifierKey
                )
                userDefaults.synchronize()
            }
        }

        if let window = UIApplication.shared.windows.last {
            hasNotch = window.safeAreaInsets.bottom > 0
        } else {
            hasNotch = false
        }
        #else
        /// <todo>
        vendorIdentifier = ""

        hasNotch = false
        #endif
    }
}

extension HIPDevice {
    public enum OS: String, Printable {
        case iOS = "iOS"
        case macOS = "macOS"
        case watchOS = "watchOS"
        case tvOS = "tvOS"

        public static var current: Self {
            #if os(macOS)
            return .macOS
            #elseif os(watchOS)
            return .watchOS
            #elseif os(tvOS)
            return .tvOS
            #else
            return .iOS
            #endif
        }
    }

    public enum Family: String, Printable {
        case iPhone
        case iPad
        case mac
        case watch
        case tv

        public static var current: Self {
            #if os(iOS)
            switch UIScreen.main.traitCollection.userInterfaceIdiom {
            case .unspecified:
                return .iPhone
            case .phone:
                return .iPhone
            case .pad:
                return .iPad
            default:
                return .iPhone
            }
            #elseif os(macOS)
            return .mac
            #elseif os(watchOS)
            return .watch
            #elseif os(tvOS)
            return .tv
            #else
            return .iPhone
            #endif
        }
    }
}

extension HIPDevice: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(model) \(os.debugDescription) \(osVersion)"
    }
}
