Pod::Spec.new do |s|
  s.name         = "iVersion"
  s.version      = "1.10.2"
  s.license      = { :type => 'zlib', :file => 'LICENCE.md' }
  s.summary      = "Library for dynamically checking for updates to Mac/iPhone App Store apps from within the application and notifying users about the new release. Can also notify users about new features in the app the first time they launch after an upgrade."
  s.homepage     = "https://github.com/nicklockwood/iVersion"
  s.authors      = { "Nick Lockwood" => "support@charcoaldesign.co.uk" }  
  s.source       = { :git => "https://github.com/nicklockwood/iVersion.git", :tag => "1.10.2" }
  s.source_files = 'iVersion'
  s.requires_arc = false
  s.ios.deployment_target = '4.3'
  s.osx.deployment_target = '10.6'
  s.ios.frameworks = 'StoreKit'
end
