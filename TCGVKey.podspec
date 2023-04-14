Pod::Spec.new do |spec|
  spec.name         = 'TCGVKey'
  spec.version      = '1.1.9.1'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/tencentyun/cloudgame-ios-sdk'
  spec.summary      = 'Tencent Cloud Gaming Software Development Kit for iOS.'
  spec.authors      = { 'lyleyu' => 'lyleyu@tencent.com' }
  spec.source       = { :path => './' }
  spec.pod_target_xcconfig = {
    'ENABLE_BITCODE' => 'OFF'
  }
  spec.vendored_frameworks = 'SDK/TCGVKey.framework'
end

