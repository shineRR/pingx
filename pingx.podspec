Pod::Spec.new do |s|
  s.name             = 'pingx'
  s.version          = '1.0.0'
  s.summary          = 'iOS library for real-time network latency estimation using ICMP packets.'
  s.description      = 'Pingx is a lightweight iOS library designed to effortlessly estimate network latency from the client to the server using ICMP (Internet Control Message Protocol) packets. This library equips iOS developers with a straightforward and efficient way to measure the round-trip time between their mobile applications and backend servers, facilitating real-time performance monitoring and optimization.'
  s.homepage         = 'https://github.com/shineRR/pingx'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ilya Baryka' => 'ilya.baryka@gmail.com' }
  s.source           = { :git => 'https://github.com/shineRR/pingx.git', :tag => s.version.to_s }
  s.source_files = 'Sources/pingx/**/*'
  s.swift_version = '5.1'

  s.ios.deployment_target = "11.0"
  s.ios.framework  = 'UIKit'

  s.tvos.deployment_target = "12.0"
  s.tvos.framework  = 'UIKit'

  s.osx.deployment_target = "10.15"
  s.osx.framework  = 'AppKit'
end
