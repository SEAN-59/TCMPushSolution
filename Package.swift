// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TCMPushSolution",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "TCMPushSolution",
            targets: ["TCMPushSolutionWrapper"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "12.0.0")
    ],
    targets: [
        // 바이너리 타겟 (v0.1.0)
        .binaryTarget(
            name: "TCMPushSolution_Core",
            url: "https://github.com/SEAN-59/TCMPushSolution/releases/download/0.1.0/TCMPushSolution.xcframework.zip",
            checksum: "d5ea2f42fa8597195d1475614969ca4b150967a4ced4dfd974d3310a68bab3e0"
        ),
        
        // 래퍼 타겟
        .target(
            name: "TCMPushSolutionWrapper", // ⭐️ 제품 이름과 동일
            dependencies: [
                "TCMPushSolution_Core",
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk")
            ],
            path: "Sources/TCMPushSolution"
        )
    ]
)
