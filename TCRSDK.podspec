Pod::Spec.new do |spec|
  spec.name         = 'TCRSDK'
  spec.version      = '3.17.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/tencentyun/cloudgame-ios-sdk'
  spec.summary      = 'Tencent Cloud Gaming Software Development Kit for iOS.'
  spec.authors      = { 'xxhapecheng' => 'xxhapecheng@tencent.com' }
  spec.source       = { :path => './' }
  # 从 3.17.0 起 TCRSDK.framework 的 MinimumOSVersion 为 15.0，声明出来可让
  # 部署版本更低的工程在 pod install 阶段就报错，而不是等到运行时才失败。
  spec.platform     = :ios, '15.0'
  spec.pod_target_xcconfig = {
    'ENABLE_BITCODE' => 'OFF'
  }
  spec.vendored_frameworks = 'SDK/TCRSDK.framework', 'SDK/TWEBRTC.framework'
  spec.info_plist = {
    'UISupportedInterfaceOrientations' => [
      'UIInterfaceOrientationPortrait',
      'UIInterfaceOrientationLandscapeLeft',
      'UIInterfaceOrientationLandscapeRight',
    ],
    'NSMicrophoneUsageDescription' => '云游戏互动时需要开启麦克风',
    'NSCameraUsageDescription' => '云游戏互动时需要开启摄像头'
  }
end

