/*
 *  Copyright 2016 The WebTCG project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "UIDevice+TCGDevice.h"

#import <sys/utsname.h>
#include <memory>

@implementation UIDevice (TCGDevice)

+ (TCGDeviceType)deviceType {
  NSDictionary *machineNameToType = @{
    @"iPhone1,1" : @(TCGDeviceTypeIPhone1G),
    @"iPhone1,2" : @(TCGDeviceTypeIPhone3G),
    @"iPhone2,1" : @(TCGDeviceTypeIPhone3GS),
    @"iPhone3,1" : @(TCGDeviceTypeIPhone4),
    @"iPhone3,2" : @(TCGDeviceTypeIPhone4),
    @"iPhone3,3" : @(TCGDeviceTypeIPhone4Verizon),
    @"iPhone4,1" : @(TCGDeviceTypeIPhone4S),
    @"iPhone5,1" : @(TCGDeviceTypeIPhone5GSM),
    @"iPhone5,2" : @(TCGDeviceTypeIPhone5GSM_CDMA),
    @"iPhone5,3" : @(TCGDeviceTypeIPhone5CGSM),
    @"iPhone5,4" : @(TCGDeviceTypeIPhone5CGSM_CDMA),
    @"iPhone6,1" : @(TCGDeviceTypeIPhone5SGSM),
    @"iPhone6,2" : @(TCGDeviceTypeIPhone5SGSM_CDMA),
    @"iPhone7,1" : @(TCGDeviceTypeIPhone6Plus),
    @"iPhone7,2" : @(TCGDeviceTypeIPhone6),
    @"iPhone8,1" : @(TCGDeviceTypeIPhone6S),
    @"iPhone8,2" : @(TCGDeviceTypeIPhone6SPlus),
    @"iPhone8,4" : @(TCGDeviceTypeIPhoneSE),
    @"iPhone9,1" : @(TCGDeviceTypeIPhone7),
    @"iPhone9,2" : @(TCGDeviceTypeIPhone7Plus),
    @"iPhone9,3" : @(TCGDeviceTypeIPhone7),
    @"iPhone9,4" : @(TCGDeviceTypeIPhone7Plus),
    @"iPhone10,1" : @(TCGDeviceTypeIPhone8),
    @"iPhone10,2" : @(TCGDeviceTypeIPhone8Plus),
    @"iPhone10,3" : @(TCGDeviceTypeIPhoneX),
    @"iPhone10,4" : @(TCGDeviceTypeIPhone8),
    @"iPhone10,5" : @(TCGDeviceTypeIPhone8Plus),
    @"iPhone10,6" : @(TCGDeviceTypeIPhoneX),
    @"iPhone11,2" : @(TCGDeviceTypeIPhoneXS),
    @"iPhone11,4" : @(TCGDeviceTypeIPhoneXSMax),
    @"iPhone11,6" : @(TCGDeviceTypeIPhoneXSMax),
    @"iPhone11,8" : @(TCGDeviceTypeIPhoneXR),
    @"iPhone12,1" : @(TCGDeviceTypeIPhone11),
    @"iPhone12,3" : @(TCGDeviceTypeIPhone11Pro),
    @"iPhone12,5" : @(TCGDeviceTypeIPhone11ProMax),
    @"iPhone12,8" : @(TCGDeviceTypeIPhoneSE2Gen),
    @"iPhone13,1" : @(TCGDeviceTypeIPhone12Mini),
    @"iPhone13,2" : @(TCGDeviceTypeIPhone12),
    @"iPhone13,3" : @(TCGDeviceTypeIPhone12Pro),
    @"iPhone13,4" : @(TCGDeviceTypeIPhone12ProMax),
    @"iPhone14,5" : @(TCGDeviceTypeIPhone13),
    @"iPhone14,4" : @(TCGDeviceTypeIPhone13Mini),
    @"iPhone14,2" : @(TCGDeviceTypeIPhone13Pro),
    @"iPhone14,3" : @(TCGDeviceTypeIPhone13ProMax),
    @"iPod1,1" : @(TCGDeviceTypeIPodTouch1G),
    @"iPod2,1" : @(TCGDeviceTypeIPodTouch2G),
    @"iPod3,1" : @(TCGDeviceTypeIPodTouch3G),
    @"iPod4,1" : @(TCGDeviceTypeIPodTouch4G),
    @"iPod5,1" : @(TCGDeviceTypeIPodTouch5G),
    @"iPod7,1" : @(TCGDeviceTypeIPodTouch6G),
    @"iPod9,1" : @(TCGDeviceTypeIPodTouch7G),
    @"iPad1,1" : @(TCGDeviceTypeIPad),
    @"iPad2,1" : @(TCGDeviceTypeIPad2Wifi),
    @"iPad2,2" : @(TCGDeviceTypeIPad2GSM),
    @"iPad2,3" : @(TCGDeviceTypeIPad2CDMA),
    @"iPad2,4" : @(TCGDeviceTypeIPad2Wifi2),
    @"iPad2,5" : @(TCGDeviceTypeIPadMiniWifi),
    @"iPad2,6" : @(TCGDeviceTypeIPadMiniGSM),
    @"iPad2,7" : @(TCGDeviceTypeIPadMiniGSM_CDMA),
    @"iPad3,1" : @(TCGDeviceTypeIPad3Wifi),
    @"iPad3,2" : @(TCGDeviceTypeIPad3GSM_CDMA),
    @"iPad3,3" : @(TCGDeviceTypeIPad3GSM),
    @"iPad3,4" : @(TCGDeviceTypeIPad4Wifi),
    @"iPad3,5" : @(TCGDeviceTypeIPad4GSM),
    @"iPad3,6" : @(TCGDeviceTypeIPad4GSM_CDMA),
    @"iPad4,1" : @(TCGDeviceTypeIPadAirWifi),
    @"iPad4,2" : @(TCGDeviceTypeIPadAirCellular),
    @"iPad4,3" : @(TCGDeviceTypeIPadAirWifiCellular),
    @"iPad4,4" : @(TCGDeviceTypeIPadMini2GWifi),
    @"iPad4,5" : @(TCGDeviceTypeIPadMini2GCellular),
    @"iPad4,6" : @(TCGDeviceTypeIPadMini2GWifiCellular),
    @"iPad4,7" : @(TCGDeviceTypeIPadMini3),
    @"iPad4,8" : @(TCGDeviceTypeIPadMini3),
    @"iPad4,9" : @(TCGDeviceTypeIPadMini3),
    @"iPad5,1" : @(TCGDeviceTypeIPadMini4),
    @"iPad5,2" : @(TCGDeviceTypeIPadMini4),
    @"iPad5,3" : @(TCGDeviceTypeIPadAir2),
    @"iPad5,4" : @(TCGDeviceTypeIPadAir2),
    @"iPad6,3" : @(TCGDeviceTypeIPadPro9Inch),
    @"iPad6,4" : @(TCGDeviceTypeIPadPro9Inch),
    @"iPad6,7" : @(TCGDeviceTypeIPadPro12Inch),
    @"iPad6,8" : @(TCGDeviceTypeIPadPro12Inch),
    @"iPad6,11" : @(TCGDeviceTypeIPad5),
    @"iPad6,12" : @(TCGDeviceTypeIPad5),
    @"iPad7,1" : @(TCGDeviceTypeIPadPro12Inch2),
    @"iPad7,2" : @(TCGDeviceTypeIPadPro12Inch2),
    @"iPad7,3" : @(TCGDeviceTypeIPadPro10Inch),
    @"iPad7,4" : @(TCGDeviceTypeIPadPro10Inch),
    @"iPad7,5" : @(TCGDeviceTypeIPad6),
    @"iPad7,6" : @(TCGDeviceTypeIPad6),
    @"iPad7,11" : @(TCGDeviceTypeIPad7Gen10Inch),
    @"iPad7,12" : @(TCGDeviceTypeIPad7Gen10Inch),
    @"iPad8,1" : @(TCGDeviceTypeIPadPro3Gen11Inch),
    @"iPad8,2" : @(TCGDeviceTypeIPadPro3Gen11Inch),
    @"iPad8,3" : @(TCGDeviceTypeIPadPro3Gen11Inch),
    @"iPad8,4" : @(TCGDeviceTypeIPadPro3Gen11Inch),
    @"iPad8,5" : @(TCGDeviceTypeIPadPro3Gen12Inch),
    @"iPad8,6" : @(TCGDeviceTypeIPadPro3Gen12Inch),
    @"iPad8,7" : @(TCGDeviceTypeIPadPro3Gen12Inch),
    @"iPad8,8" : @(TCGDeviceTypeIPadPro3Gen12Inch),
    @"iPad8,9" : @(TCGDeviceTypeIPadPro4Gen11Inch),
    @"iPad8,10" : @(TCGDeviceTypeIPadPro4Gen11Inch),
    @"iPad8,11" : @(TCGDeviceTypeIPadPro4Gen12Inch),
    @"iPad8,12" : @(TCGDeviceTypeIPadPro4Gen12Inch),
    @"iPad11,1" : @(TCGDeviceTypeIPadMini5Gen),
    @"iPad11,2" : @(TCGDeviceTypeIPadMini5Gen),
    @"iPad11,3" : @(TCGDeviceTypeIPadAir3Gen),
    @"iPad11,4" : @(TCGDeviceTypeIPadAir3Gen),
    @"iPad11,6" : @(TCGDeviceTypeIPad8),
    @"iPad11,7" : @(TCGDeviceTypeIPad8),
    @"iPad12,1" : @(TCGDeviceTypeIPad9),
    @"iPad12,2" : @(TCGDeviceTypeIPad9),
    @"iPad13,1" : @(TCGDeviceTypeIPadAir4Gen),
    @"iPad13,2" : @(TCGDeviceTypeIPadAir4Gen),
    @"iPad13,4" : @(TCGDeviceTypeIPadPro5Gen11Inch),
    @"iPad13,5" : @(TCGDeviceTypeIPadPro5Gen11Inch),
    @"iPad13,6" : @(TCGDeviceTypeIPadPro5Gen11Inch),
    @"iPad13,7" : @(TCGDeviceTypeIPadPro5Gen11Inch),
    @"iPad13,8" : @(TCGDeviceTypeIPadPro5Gen12Inch),
    @"iPad13,9" : @(TCGDeviceTypeIPadPro5Gen12Inch),
    @"iPad13,10" : @(TCGDeviceTypeIPadPro5Gen12Inch),
    @"iPad13,11" : @(TCGDeviceTypeIPadPro5Gen12Inch),
    @"iPad14,1" : @(TCGDeviceTypeIPadMini6),
    @"iPad14,2" : @(TCGDeviceTypeIPadMini6),
    @"i386" : @(TCGDeviceTypeSimulatori386),
    @"x86_64" : @(TCGDeviceTypeSimulatorx86_64),
  };

  TCGDeviceType deviceType = TCGDeviceTypeUnknown;
  NSNumber *typeNumber = machineNameToType[[self machineName]];
  if (typeNumber) {
    deviceType = static_cast<TCGDeviceType>(typeNumber.integerValue);
  }
  return deviceType;
}

+ (NSString *)machineName {
  struct utsname systemInfo;
  uname(&systemInfo);
  return [[NSString alloc] initWithCString:systemInfo.machine
                                  encoding:NSUTF8StringEncoding];
}

+ (double)currentDeviceSystemVersion {
  return [self currentDevice].systemVersion.doubleValue;
}

+ (BOOL)isIOS11OrLater {
  return [self currentDeviceSystemVersion] >= 11.0;
}

@end
