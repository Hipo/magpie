// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Magpie",
    platforms: [.iOS(.v11), .macOS(.v10_15)],
    products: [
        .library(name: "MagpieAlamofire", targets: ["MagpieAlamofire"]),
        .library(name: "MagpieCore", targets: ["MagpieCore"]),
        .library(name: "MagpieExceptions", targets: ["MagpieExceptions"]),
        .library(name: "MagpieHipo", targets: ["MagpieHipo"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.4.0")),
        .package(name: "MacaroonUtils", url: "https://github.com/Hipo/macaroon-utils.git", .upToNextMajor(from: "3.0.0")),
    ],
    targets: [
        .target(name: "MagpieAlamofire", dependencies: ["MagpieCore", "Alamofire"], path: "Sources/MagpieAlamofire"),
        .target(name: "MagpieCore", dependencies: ["MacaroonUtils"], path: "Sources/MagpieCore"),
        .target(name: "MagpieExceptions", dependencies: ["MagpieCore"], path: "Sources/MagpieExceptions"),
        .target(name: "MagpieHipo", dependencies: ["MagpieAlamofire", "MagpieExceptions"], path: "Sources/MagpieHipo"),
        .testTarget(name: "MagpieTests",dependencies: ["MagpieCore"])
    ],
    swiftLanguageVersions: [.v5]
)
