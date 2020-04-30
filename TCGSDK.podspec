Pod::Spec.new do |spec|
  spec.name         = "TCGSDK"
  spec.version      = "0.2.1"
  spec.summary      = "Tencent Cloud Gaming Software Development Kit"
  spec.license      = "MIT"

  spec.description  = <<-DESC
Tencent Cloud Gaming Software Development Kit.
                   DESC

  spec.homepage     = "https://git.code.oa.com/cloud_video_product_private/cloud_gaming"

  spec.author             = { "okhowang(王沛文)" => "okhowang@tencent.com" }

  spec.ios.deployment_target = '9.0'

  spec.source       = { :git => 'https://github.com/tencentyun/cloudgame-ios-sdk.git', :tag => spec.version.to_s }

  spec.source_files  = "tcgsdk/*.{h,m}"

  spec.public_header_files = "tcgsdk/{tcgsdk,TcgSdkDelegate,TcgSdkParams,TcgSdkEvent,TcgSdkLogger,TcgSdkReport}.h"

  spec.resources = "resource/**"

  spec.pod_target_xcconfig = {
    'ENABLE_BITCODE' => 'OFF'
  }

  spec.requires_arc = true

  spec.dependency "GoogleWebRTC"

  spec.info_plist = {
    # 'CFBundleIdentifier' => 'com.tencent.cloudgaming',
    # https://github.com/CocoaPods/CocoaPods/issues/9536
  }
end
