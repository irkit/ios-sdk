osx_source_files = %w{Log IRKit IRKit+Internal IRPersistentStore IRHelper IRHTTPJSONOperation IRHTTPOperationQueue IRHTTPClient IRReachability IRPeripheral IRPeripherals IRSignal IRSignals IRSignalSequence IRSignalSendOperationQueue IRSignalSendOperation IRSearcher IRUserDefaultsStore IRConst}

Pod::Spec.new do |s|
  s.name         = "IRKit"
  s.version      = "3.0.0"
  s.summary      = "Send/Receive Infrared signals via IRKit device."
  s.description  = <<-DESC
                     IRKit device and SDK(this library) lets you control your home electronics from your iOS devices.
                     IRKit device has a Infrared LED and receiver, and a WiFi module inside.
                     WiFi enabled devices (such as your iOS device) can connect with IRKit devices, and make it send IR signals for you.
                     This library does:
                     * provide UIViewController subclasses that wraps complex procedures to connect and receive IR signals(to learn before sending) from IRKit devices
                     * provide a simple interface to send IR signals
                    DESC
  s.homepage     = "http://github.com/irkit/ios-sdk"
  s.license      = 'MIT'
  s.author       = { "Masakazu OHTSUKA" => "o.masakazu@gmail.com" }
  s.source       = { :git => "https://github.com/irkit/ios-sdk.git", :tag => "3.0.0" }
  s.ios.deployment_target = '6.0'
  # s.osx.deployment_target = '10.9'
  s.ios.source_files = 'IRKit/IRKit/*.{h,m,c}'
  # s.osx.source_files = osx_source_files.map { |file| "IRKit/IRKit/#{file}.{h,m,c}" }
  s.public_header_files = 'IRKit/IRKit/'

  s.resources    = 'IRKit/IRKit.bundle'
  s.ios.frameworks   = 'Foundation', 'QuartzCore', 'CoreGraphics', 'CoreTelephony', 'UIKit', 'MediaPlayer', 'SystemConfiguration', 'AudioToolbox', 'AVFoundation'
  # s.osx.frameworks   = 'Foundation', 'QuartzCore', 'CoreGraphics', 'SystemConfiguration'
  s.library      = 'c++'
  s.requires_arc = true
  s.dependency 'ISHTTPOperation'
end
