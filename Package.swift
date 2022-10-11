// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ConnectKit",
  platforms: [
    .macOS(.v10_14),
    .macCatalyst(.v13),
    .iOS(.v12),
    .tvOS(.v12),
  ],
  products: [
    .library(
      name: "ConnectKit",
      targets: [
        "ConnectKit",
        "ConnectV2",
        "ForeFlight",
        "OpenTrack",])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "ConnectKit",
      dependencies: ["_ConnectKitCommon",
                     "ConnectV2",
                     "ForeFlight",
                     "OpenTrack"],
      path: "Sources/ConnectKit"),
    .target(
      name: "_ConnectKitCommon",
      dependencies: [],
      path: "Sources/Common"),
    .target(
      name: "ConnectV2",
      dependencies: ["_ConnectKitCommon"],
      path: "Sources/ConnectV2"),
    .target(
      name: "ForeFlight",
      dependencies: ["_ConnectKitCommon"],
      path: "Sources/ForeFlight"),
    .target(
      name: "OpenTrack",
      dependencies: ["_ConnectKitCommon"],
      path: "Sources/OpenTrack"),
  ]
)
