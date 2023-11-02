// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "XRay",
  platforms: [.iOS(.v12)],
  products: [
    .library(name: "XRay", targets: ["XRay"])
  ],
  targets: [
    .binaryTarget(
      name: "XRay",
      url: "https://github.com/EbrahimTahernejad/xray-mobile/releases/download/1.8.1/XRay.xcframework.zip",
      checksum: "803a4561f614971744b044fe2943710025297cb6064f78824f55f7f9f1f46fb0"
    )
  ]
)
