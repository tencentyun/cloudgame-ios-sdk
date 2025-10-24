Pod::Spec.new do |spec|
  spec.name         = 'TCRPROXYSDK'
  spec.version      = '1.2.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/tencentyun/cloudgame-ios-sdk'
  spec.summary      = 'Tencent Cloud Gaming Software Development Kit for iOS.'
  spec.authors      = { 'tyrionchen' => 'tyrionchen@tencent.com' }
  spec.source       = { :path => './' }
  spec.pod_target_xcconfig = {
    'ENABLE_BITCODE' => 'OFF'
  }
  spec.vendored_frameworks = 'SDK/TCRPROXYSDK.xcframework'
end

