// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "zego_uikit_prebuilt_call",
    platforms: [.iOS("15.0")],
    products: [.library(name: "zego-uikit-prebuilt-call", targets: ["zego_uikit_prebuilt_call"])],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "zego_uikit_prebuilt_call",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            cSettings: [.headerSearchPath("include/zego_uikit_prebuilt_call")]
        )
    ]
)
