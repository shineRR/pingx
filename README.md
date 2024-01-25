# pingx

[![CI Status](https://img.shields.io/travis/shineRR/pingx.svg?style=flat)](https://travis-ci.org/shineRR/pingx)
[![Version](https://img.shields.io/cocoapods/v/pingx.svg?style=flat)](https://cocoapods.org/pods/pingx)
[![License](https://img.shields.io/cocoapods/l/pingx.svg?style=flat)](https://cocoapods.org/pods/pingx)
[![Platform](https://img.shields.io/cocoapods/p/pingx.svg?style=flat)](https://cocoapods.org/pods/pingx)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

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

## Integration

Import the pingx module into your Swift code and initialize the Pinger instance.

```swift
import pingx

let pinger = SinglePinger()
let destination = IPv4Address(address: (8, 8, 8, 8))
let request = Request(destination: destination)
pinger.ping(request: request)
```

## Author

pingx is developed and maintained by [Ilya Baryka](https://www.linkedin.com/in/ilya-baryka/).

* LinkedIn: [@shineRR](https://www.linkedin.com/in/ilya-baryka/)
* GitHub: [@shineRR](https://github.com/shineRR)

## License

pingx is available under the MIT license. See the LICENSE file for more info.
