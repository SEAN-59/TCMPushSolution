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
        // 바이너리 타겟 (v0.1.2)
        .binaryTarget(
            name: "TCMPushSolution_Core",
            url: "https://github.com/SEAN-59/TCMPushSolution/releases/download/0.1.2/TCMPushSolution.xcframework.zip",
            checksum: "358cea59fa3666ee961a3b7987646cb202a5830f3f201f4b8c3f92aee8697217"
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
