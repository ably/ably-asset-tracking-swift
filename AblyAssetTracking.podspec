Pod::Spec.new do |s|
  s.name = 'AblyAssetTracking'
  s.version = '0.0.1'
  s.summary = 'Ably Asset Tracking Client'
  s.homepage = "https://www.ably.com"
  s.license = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author = { "Ably" => "support@ably.com" }
  s.source = { :git => "." }
  s.ios.deployment_target  = '12.0'
  s.swift_version = '5.0'
  s.source       = { :git => 'https://github.com/ably/ably-asset-tracking-cocoa.git',  :tag => "#{s.version}"}
  s.social_media_url = 'https://twitter.com/ablyrealtime'
  s.source_files = 'Sources/**/*.swift'
end
