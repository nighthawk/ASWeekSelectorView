// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ASWeekSelectorView",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(
      name: "ASWeekSelectorView",
      targets: ["ASWeekSelectorView"]
    ),
  ],
  targets: [
    .target(
      name: "ASWeekSelectorView"
    ),
  ]
)
