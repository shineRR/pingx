# pingx

[![Version](https://img.shields.io/cocoapods/v/pingx.svg?style=flat)](https://cocoapods.org/pods/pingx)
[![License](https://img.shields.io/cocoapods/l/pingx.svg?style=flat)](https://cocoapods.org/pods/pingx)
[![codecov](https://codecov.io/gh/shineRR/pingx/graph/badge.svg?token=OJSHN8KMHJ)](https://codecov.io/gh/shineRR/pingx)
[![codebeat badge](https://codebeat.co/badges/c7617707-3b8c-4c41-9094-aa152757df55)](https://codebeat.co/projects/github-com-shinerr-pingx-main)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/98fb2f3d80c64d7d88ee725e3038a6db)](https://app.codacy.com/gh/shineRR/pingx/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![Platform](https://img.shields.io/cocoapods/p/pingx.svg?style=flat)](https://cocoapods.org/pods/pingx)

## Introduction

**pingx** is a lightweight Swift library for determining network latency between a client and server using ICMP (Internet Control Message Protocol) packets. It provides a simple and flexible API for sending and managing ping requests to IPv4 addresses.

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
    .package(url: "https://github.com/shineRR/pingx", .upToNextMajor(from: "1.1.0"))
]
```

## Usage

### IPv4 Address Conversion

```swift
import pingx

let converter = IPv4AddressStringConverter()
let destination = try converter.convert(address: "8.8.8.8")
```

### Request

The Request class represents a single ping request configuration. It encapsulates all necessary information to perform an ICMP ping to a specified IPv4 address.

```swift
import pingx

let destination = IPv4Address(address: (8, 8, 8, 8))
let request = Request(
    destination: destination,       // Destination
    timeoutInterval: .seconds(1),   // Timeout interval. Available options for timeout interval: .seconds, .milliseconds, .nanoseconds
    demand: .max(5)                 // Send 5 ping requests (default is 1).
)                                   // Available options for demand:
                                    // - .none: send no requests
                                    // - .max(n): send up to n requests
                                    // - .unlimited: send unlimited requests

```

### Asynchronous Pinging

Ping example:
```swift
import pingx

let pinger = AsyncPinger()
let request = Request(destination: destination)
let sequence = pinger.ping(request: request)

for try await result in sequence {
    print("Result: \(result)")
}
```

### Callback-based Pinging

Ping example:
```swift
import pingx

let pinger = Pinger()
let request = Request(destination: destination)

pinger.ping(request: request) { result in
    print("Result: \(result)")
}
```

Request cancellation example:
```swift
import pingx

let pinger = Pinger()
let request = Request(destination: destination)

pinger.ping(request: request) { result in
    print("Result: \(result)")
}
pinger.cancel(requestId: request.id)
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

pingx is developed and maintained by [shineRR](https://github.com/shineRR).

## License

pingx is available under the MIT license. See the LICENSE file for more info.
