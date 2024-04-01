Pod::Spec.new do |s|
  s.name             = 'pingx'
  s.version          = '1.0.3'
  s.summary          = 'pingx: iOS library for ping estimation using ICMP packets.'
  s.description      = 'This ultralight and easy-to-use library is designed to help developers accurately measure and analyze network ping latency in their applications using ICMP packets.'
  s.homepage         = 'https://github.com/shineRR/pingx'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ilya Baryka' => 'ilya.baryka@gmail.com' }
  s.source           = { :git => 'https://github.com/shineRR/pingx.git', :tag => s.version.to_s }
  s.source_files     = 'Sources/pingx/**/*'
  s.swift_version    = '5.1'

  s.ios.deployment_target = "12.0"
  s.ios.framework  = 'UIKit'

  s.tvos.deployment_target = "12.0"
  s.tvos.framework = 'UIKit'

  s.osx.deployment_target = "10.15"
  s.osx.framework  = 'AppKit'
end
