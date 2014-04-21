Pod::Spec.new do |s|
  s.name         = "IRKit"
  s.version      = "1.0.1"
  s.summary      = "Send/Receive Infrared signals via IRKit device."
  s.description  = <<-DESC
                     IRKit device and SDK(this library) lets you control your home electronics from your iOS devices.
                     IRKit device has a Infrared LED and receiver, and a WiFi module inside.
                     WiFi enabled devices (such as your iOS device) can connect with IRKit devices, and make it send IR signals for you.
                     This library does:
                     * provide UIViewController subclasses that wraps complex procedures to connect and receive IR signals(to learn before sending) from IRKit devices
                     * provide a simple interface to send IR signals
                    DESC
  s.homepage     = "http://irkit.github.io/"
  s.license      = 'MIT'
  s.author       = { "Masakazu OHTSUKA" => "o.masakazu@gmail.com" }
  s.source       = { :git => "https://github.com/irkit/ios-sdk.git", :tag => "1.0.1" }
  s.platform     = :ios, '6.0'
  s.source_files = 'IRKit/IRKit/*.{h,m,c}'
  s.public_header_files = 'IRKit/IRKit/'
  s.preserve_paths = 'IRKit.framework/*'
  s.vendored_frameworks = 'IRKit/IRKit.framework'

  s.resources    = 'IRKit/IRKit.bundle'
  s.frameworks   = 'Foundation', 'QuartzCore', 'CoreGraphics', 'CoreTelephony', 'UIKit', 'MediaPlayer', 'SystemConfiguration', 'AudioToolbox', 'AVFoundation'
  s.library      = 'c++'
  s.requires_arc = true
  s.dependency 'ISHTTPOperation', '~> 1.1.0'
end
