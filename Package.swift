// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SFMobileAppMessagingSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "MobileAppMessagingSDK",
            targets: ["MobileAppMessagingSDKWrapper"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/salesforce-marketingcloud/sfmc-sdk-ios", from: "3.0.0"),
    ],
    targets: [
        .binaryTarget(
            name: "MobileAppMessagingSDK",
            path: "Frameworks/MobileAppMessagingSDK.xcframework"
        ),
        .target(
            name: "MobileAppMessagingSDKWrapper",
            dependencies: [
                .target(name: "MobileAppMessagingSDK"),
                .product(name: "SFMCSDK", package: "sfmc-sdk-ios")
            ],
            path: "Frameworks/MobileAppMessagingSDK"
        )
    ]
)
