// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "RTSearchBar",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11)
    ],
    products: [
        .library(name: "RTSearchBar", targets: ["RTSearchBar"]),
    ],
    targets: [
        .target(name: "RTSearchBar")],
    swiftLanguageVersions: [.v5]
)
