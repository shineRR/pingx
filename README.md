# pingx

[![Version](https://img.shields.io/cocoapods/v/pingx.svg?style=flat)](https://cocoapods.org/pods/pingx)
[![License](https://img.shields.io/cocoapods/l/pingx.svg?style=flat)](https://cocoapods.org/pods/pingx)
[![codecov](https://codecov.io/gh/shineRR/pingx/graph/badge.svg?token=OJSHN8KMHJ)](https://codecov.io/gh/shineRR/pingx)
[![codebeat badge](https://codebeat.co/badges/c7617707-3b8c-4c41-9094-aa152757df55)](https://codebeat.co/projects/github-com-shinerr-pingx-main)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/98fb2f3d80c64d7d88ee725e3038a6db)](https://app.codacy.com/gh/shineRR/pingx/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![Platform](https://img.shields.io/cocoapods/p/pingx.svg?style=flat)](https://cocoapods.org/pods/pingx)

## Introduction

 This ultralight and easy-to-use library is designed to help developers accurately measure and analyze network ping latency in their applications. Whether you're working on a project that requires real-time communication, online gaming, or network performance monitoring, this library provides a seamless solution to assess and optimize ping times.

## Installation

### CocoaPods

To integrate pingx into your Xcode project using CocoaPods, add the following line to your Podfile:

```ruby
pod 'pingx'
```

Then, run the following command:

```ruby
$ pod install
```

### Swift Package Manager (SPM)

To integrate pingx into your Xcode project using Swift Package Manager, add the following dependency to your Package.swift file:

```swift
dependencies: [
    .package(url: "https://github.com/shineRR/pingx", .upToNextMajor(from: "1.0.0"))
]
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Integration

Import the pingx module into your Swift code and initialize the Pinger instance.

```swift
import pingx

let pinger = ContinuousPinger()
pinger.delegate = self

let destination = IPv4Address(address: (8, 8, 8, 8))
let request = Request(destination: destination, demand: .unlimited)

pinger.ping(request: request)
```

## Author

pingx is developed and maintained by [shineRR](https://github.com/shineRR).

## License

pingx is available under the MIT license. See the LICENSE file for more info.
