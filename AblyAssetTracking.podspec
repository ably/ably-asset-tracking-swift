Pod::Spec.new do |spec|
  spec.name = 'AblyAssetTracking'
  spec.version = '0.0.1'
  spec.summary = 'Ably Asset Tracking Client'
  spec.homepage = "https://www.ably.com"
  spec.license = { :type => 'Apache 2.0', :file => 'LICENSE' }
  spec.author = { "Ably" => "support@ably.com" }
  spec.source = { :git => "." }
  spec.ios.deployment_target  = '12.0'
  spec.swift_version = '5.0'
end